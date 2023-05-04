
CREATE procedure [dbo].[st_ResponseReturnCodePontual]                                        
(                                        
    @IdGateway  int,
    @Claimcode  nvarchar(max),
    @ReturnCode nvarchar(max),
    @ReturnCodeType int,
    @XmlValue xml,
    @IsCorrect bit = 0 out,
	@MessageOUT varchar(max) = out 
)                                   
AS  


/********************************************************************
<Author></Author>
<app>  </app>
<Description></Description>
<SampleCall></SampleCall>
<ChangeLog>
<log Date="10/12/2018" Author="adominguez">Se agrega "with(nolock)" a las consultas</log>
<log Date="12/12/2018" Author="jmolina">Se agrega "cast a mimsmo tamaño de variable y campo de tabla y se comenta funcionalidad de moneyalert" a las consultas #1</log>
<log Date="27/10/2020" Author="jgomez"> CR - M00290, Se agrega validacion para no insertar otro cambio de estatus para cuando este cancelada o rechazada</log>
<log Date="12/11/2020" Author="jgomez"> CR - M00290, Se agrega validacion logs</log>
</ChangeLog>
*********************************************************************/                                
Set nocount on                                  
Declare @Description nvarchar(max)                                    
Declare @IdStatusAction int                                    
Declare @IdTransfer int          
Declare @ActualIdStatus int                                   
Declare @str varchar(max)     
declare @ReturnAllComission int    

set @str=''
begin try

Select @IdStatusAction=A.IdStatusAction,@Description=B.ReturnCodeType+' code '+@ReturnCode+','+Description
from GatewayReturnCode A WITH(NOLOCK) Join GatewayReturnCodeType B WITH(NOLOCK) on (A.IdGatewayReturnCodeType=B.IdGatewayReturnCodeType)
where A.IdGateway=@IdGateway And A.IdGatewayReturnCodeType=@ReturnCodeType And A.ReturnCode=@ReturnCode

if exists (SELECT TOP 1 * from Transfer WITH(NOLOCK) where ClaimCode = @Claimcode AND IdStatus in (31, 22, 23,40, 24, 29, 27)) --CR - M00290
begin 
if @ReturnCodeType=1
   BEGIN 
     set @IdStatusAction = 0
 END
END -- END CR - M00290

Insert into [MAXILOG].[dbo].PontualResponseLog values (getdate(),@Claimcode,@ReturnCode,@ReturnCodeType,@IdStatusAction,@Description,@XmlValue)

If @ReturnCodeType=1
BEGIN
	Declare @DocHandle2 int,
		@OrderID varchar(max)
	 EXEC sp_xml_preparedocument @DocHandle2 OUTPUT, @XmlValue
	 SELECT @OrderID=OrderID FROM OPENXML (@DocHandle2, 'NewOrderResponse',2)  WITH (OrderID varchar(max),AgentOrderReference varchar(max))
	 EXEC sp_xml_removedocument @DocHandle2
END

If @ReturnCodeType=3
Begin
 Declare @DocHandle int
 EXEC sp_xml_preparedocument @DocHandle OUTPUT, @XmlValue
 SELECT Name+'='+Value as variable  into #temp FROM OPENXML (@DocHandle, 'root/Variable',2)  WITH (Name varchar(max),Value varchar(max))
 EXEC sp_xml_removedocument @DocHandle

 SELECT @str = COALESCE(@str + ';', '') + variable FROM #temp
 Set @Description=@Description+' '+@str
End

Select 
    @IdTransfer=IdTransfer,
    @ActualIdStatus=IdStatus,
    @ReturnAllComission=ReturnAllComission 
From Transfer t
left join 
    ReasonForCancel r on t.IdReasonForCancel=r.IdReasonForCancel
where ClaimCode=@Claimcode

 if(@ReturnCodeType =1 and @OrderID is not null)
		INSERT INTO [dbo].[PontualOrderID] ([IdTransfer],[OrderID]) values (@IdTransfer,@OrderID)

--Validar razon de cancelacion
set @ReturnAllComission=isnull(@ReturnAllComission,0)

If @IdStatusAction>0
Begin
	if @IdTransfer is not null and @ActualIdStatus<>@IdStatusAction
	begin
		Update Transfer set IdStatus=@IdStatusAction,DateStatusChange=GETDATE() where IdTransfer=@IdTransfer
		Exec st_SaveChangesToTransferLog @IdTransfer,@IdStatusAction,@Description,0
		If @IdStatusAction=31 --- Rejected balance
		Begin
			Exec st_RejectedCreditToAgentBalance @IdTransfer
		End
		If @IdStatusAction=22  -- Cancel Balance
		Begin
			If not exists(Select 1 from TransfersUnclaimed WITH(NOLOCK) where IdTransfer=@IdTransfer and IdStatus=1)
			begin
                if (@ReturnAllComission=0)--validar si se regresa completa la comision
				    Exec st_CancelCreditToAgentBalance @IdTransfer 
                else
                    EXEC st_CancelCreditToAgentBalanceTotalAmount  @IdTransfer
            end
			Else
			Begin
				Declare @UnclaimedStatus int
				set @UnclaimedStatus=27
				Update TransfersUnclaimed set IdStatus=2 where IdTransfer=@IdTransfer
				Update Transfer set IdStatus=@UnclaimedStatus,DateStatusChange=GETDATE() where IdTransfer=@IdTransfer
				Exec st_SaveChangesToTransferLog @IdTransfer,@UnclaimedStatus,@Description,0
			End
		End
        If @IdStatusAction=30  -- Paid
		Begin
            exec st_SavePayInfoPontual @IdGateway,@IdTransfer,@Claimcode,@XmlValue
        End
        if (@IdStatusAction in (22,30,31))
        begin
            DECLARE	@HasErrorD bit,	@MessageOutD varchar(max)

            EXEC	[dbo].[st_DismissComplianceNotificationByIdTransfer]
	        	@IdTransfer,
		        1,
		        @HasErrorD OUTPUT,
		        @MessageOutD OUTPUT
        end
	End
End
Else
Begin
	Select @Description='Return code UNKNOWN:'+@ReturnCode+' '+@str
	Exec st_SimpleAddNoteToTransfer  @IdTransfer,@Description
End
Set @IsCorrect=1

End Try
Begin Catch
 Set @IsCorrect=1                                                                                   
 Select @MessageOut = dbo.GetMessageFromLenguajeResorces (1,80)  
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[dbo].[st_ResponseReturnCodePontual]',Getdate(),ERROR_MESSAGE())    
End Catch
