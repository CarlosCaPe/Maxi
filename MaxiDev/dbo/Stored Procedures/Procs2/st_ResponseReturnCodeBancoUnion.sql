CREATE procedure [dbo].[st_ResponseReturnCodeBancoUnion]                                              
(                                              
    @IdGateway  int,                                              
    @Claimcode  nvarchar(max),                                              
    @ReturnCode nvarchar(max),                                              
    @ReturnCodeType int,                                         
    @XmlValue xml,                                        
    @IsCorrect bit Output                                        
)                                         
AS

/********************************************************************
<Author></Author>
<app>  </app>
<Description></Description>
<SampleCall></SampleCall>
<ChangeLog>
<log Date="10/12/2018" Author="adominguez">Se agrega "with(nolock)" a las consultas</log>
<log Date="12/12/2018" Author="jmolina">Se agrega "cast a mimsmo tamaño de variable a las consultas #1</log>
</ChangeLog>
*********************************************************************/

Set nocount on
BEGIN TRY
	Declare @Description nvarchar(max)                                          
	Declare @IdStatusAction int                                          
	Declare @IdTransfer int                                          
	Declare @ActualIdStatus Int
	Declare @str varchar(max)
	declare @ReturnAllComission int 

	declare @ReturnCodeCast nvarchar(16)
	declare @ClaimcodeCast nvarchar(50)

	set @ReturnCodeCast = convert(nvarchar(16), @ReturnCode)
	set @ClaimcodeCast = convert(nvarchar(50), @Claimcode)

	set @str=''
                                          
	Select @IdStatusAction=A.IdStatusAction,@Description=B.ReturnCodeType+' code '+@ReturnCodeCast+','+[Description]
	--Select @IdStatusAction=A.IdStatusAction,@Description=B.ReturnCodeType+' code '+@ReturnCode+','+[Description]
	from GatewayReturnCode as A with(nolock)  
	inner Join GatewayReturnCodeType as B with(nolock) on (A.IdGatewayReturnCodeType=B.IdGatewayReturnCodeType)   
	where A.IdGateway=@IdGateway And A.IdGatewayReturnCodeType=@ReturnCodeType And A.ReturnCode=@ReturnCodeCast
	--where A.IdGateway=@IdGateway And A.IdGatewayReturnCodeType=@ReturnCodeType And A.ReturnCode=@ReturnCode
                                          
	Insert into BancoUnionResponseLog values (getdate(),@Claimcode,@ReturnCode,@ReturnCodeType,@IdStatusAction,@Description,@XmlValue)                      
                  
	If @ReturnCodeType=3                  
	Begin                  
	 Declare @DocHandle int                            
	 EXEC sp_xml_preparedocument @DocHandle OUTPUT, @XmlValue                             
	 SELECT Name+'='+Value as variable  into #temp FROM OPENXML (@DocHandle, 'root/Variable',2)  WITH (Name varchar(max),Value varchar(max))                                   
	 EXEC sp_xml_removedocument @DocHandle                                     
                   
	 SELECT @str = COALESCE(@str + ';', '') + variable FROM #temp                  
	 Set @Description=@Description+' '+@str                  
	End                    
  
	--Select @IdTransfer=IdTransfer from ConsecutivoPagosInt where IdConsecutivoPagosInt= CONVERT(int,@Claimcode)  
	Select @IdTransfer=IdTransfer from [transfer] with(nolock) where claimcode = @ClaimcodeCast --@Claimcode

	Select @ActualIdStatus=IdStatus,
		   @ReturnAllComission=ReturnAllComission 
	From [Transfer] as t with(nolock)
	left join 
		ReasonForCancel as r with(nolock) on t.IdReasonForCancel=r.IdReasonForCancel
	where IdTransfer=@IdTransfer   

	--Validar razon de cancelacion
	set @ReturnAllComission=isnull(@ReturnAllComission,0)                                    
                            
	If @IdStatusAction>0           
	Begin                                            
		If @IdTransfer is not null and @ActualIdStatus<>@IdStatusAction                                                                       
		Begin                 
	
		Declare @IdStatuTransfer Int 

		If(@IdStatusAction = 30) 
		Begin
				 Set @IdStatuTransfer = (Select IdStatus From [Transfer] WITH(NOLOCK)  Where IdTransfer=@IdTransfer) 
			 
				 If (@IdStatuTransfer <> 23)
				 Begin

					Declare @DescriptionPaymetReady nvarchar(max)        

					set @DescriptionPaymetReady='NOTIFICATION, Lista para ser entregada'   

			 		Update [Transfer] set IdStatus=23,DateStatusChange=GETDATE() Where IdTransfer=@IdTransfer                                            
					Exec st_SaveChangesToTransferLog @IdTransfer,23,@DescriptionPaymetReady,0                         
				

				 End
			      
		End
	                          
			Update [Transfer] set IdStatus=@IdStatusAction,DateStatusChange=GETDATE() where IdTransfer=@IdTransfer                                            
			Exec st_SaveChangesToTransferLog @IdTransfer,@IdStatusAction,@Description,0                         
			If @IdStatusAction=31 --- Rejected balance                        
			Begin                        
				Exec st_RejectedCreditToAgentBalance @IdTransfer                        
			End                         
			If @IdStatusAction=22  -- Cancel Balance                        
			Begin  
				If not exists(Select 1 from TransfersUnclaimed with(nolock) where IdTransfer=@IdTransfer and IdStatus=1)	                                                     
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
					Update [Transfer] set IdStatus=@UnclaimedStatus,DateStatusChange=GETDATE() where IdTransfer=@IdTransfer  
					Exec st_SaveChangesToTransferLog @IdTransfer,@UnclaimedStatus,@Description,0
				End
			End
			If @IdStatusAction=30  -- Paid
			Begin
				exec st_SavePayInfoBancoUnion @IdGateway,@IdTransfer,@Claimcode,@XmlValue
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
		Select @Description='Return code UNKNOWN:'+@ReturnCode                              
		Exec st_SimpleAddNoteToTransfer  @IdTransfer,@Description                              
	End                              
	Set @IsCorrect=1
END TRY
BEGIN CATCH
	--Set @IsCorrect=0
	DECLARE @Error nvarchar(max)
	SELECT @Error= 'Line: ' + CONVERT(varchar(10), ERROR_LINE()) + ', Error: ' + ERROR_MESSAGE()
	INSERT INTO dbo.ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ResponseReturnCodeBancoUnion',Getdate(),@Error)

	--DECLARE @Parameters VARCHAR(MAX) = (SELECT * FROM (SELECT IdGateway = @IdGateway, Claimcode = @Claimcode, ReturnCode = @ReturnCode, ReturnCodeType = @ReturnCodeType) AS t FOR XML PATH('Parameters'), ELEMENTS)
	--INSERT INTO Soporte.InfoLogForStoreProcedure(StoreProcedure, InfoDate, InfoMessage, ExtraData) VALUES('st_ResponseReturnCodeBancoUnion', GETDATE(), @Parameters, CONVERT(VARCHAR(MAX), @XmlValue))
END CATCH