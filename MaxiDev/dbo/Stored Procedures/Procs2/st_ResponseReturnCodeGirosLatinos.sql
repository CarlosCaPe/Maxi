CREATE procedure [dbo].[st_ResponseReturnCodeGirosLatinos]                                  
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
<log Date="12/12/2018" Author="jmolina">Se agrega "cast a mimsmo tamaño de variable y campo de tabla y se comenta funcionalidad de moneyalert" a las consultas #1</log>
</ChangeLog>
*********************************************************************/
Set nocount on                            
Declare @Description nvarchar(max)                              
Declare @IdStatusAction int                              
Declare @IdTransfer int    
Declare @ActualIdStatus int 
Declare @str varchar(max)
declare @ReturnAllComission int  

BEGIN TRY
	declare @ReturnCodeCast nvarchar(16)
	declare @ClaimcodeCast nvarchar(50)

	set @ReturnCodeCast = convert(nvarchar(16), @ReturnCode)
	set @ClaimcodeCast = convert(nvarchar(50), @Claimcode)

	set @str=''
                              
	Select @IdStatusAction=A.IdStatusAction,@Description=B.ReturnCodeType+' code '+@ReturnCode+','+[Description]                   
	from GatewayReturnCode AS A with(nolock)  
	inner Join GatewayReturnCodeType as B with(nolock) on (A.IdGatewayReturnCodeType=B.IdGatewayReturnCodeType)                  
	where A.IdGateway=@IdGateway And A.IdGatewayReturnCodeType=@ReturnCodeType And A.ReturnCode=@ReturnCodeCast
	--where A.IdGateway=@IdGateway And A.IdGatewayReturnCodeType=@ReturnCodeType And A.ReturnCode=@ReturnCode

	Insert into  [MAXILOG].[dbo].GirosLatinosResponseLog values (getdate(),@Claimcode,@ReturnCode,@ReturnCodeType,@IdStatusAction,@Description,@XmlValue)          
        
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
	From [Transfer] AS t with(nolock)
	left join 
		ReasonForCancel AS r with(nolock) on t.IdReasonForCancel=r.IdReasonForCancel
	where ClaimCode=@ClaimcodeCast
	--where ClaimCode=@Claimcode

	--Validar razon de cancelacion
	set @ReturnAllComission=isnull(@ReturnAllComission,0)                           
                
	If @IdStatusAction>0
	Begin
		if @IdTransfer is not null and @ActualIdStatus<>@IdStatusAction
		begin
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
				exec st_SavePayInfoGirosLatinos @IdGateway,@IdTransfer,@Claimcode,@XmlValue
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

		-- Se comenta debido que este servicio dejo de funcionar para MAXI	
	--Begin Try  --#1
	--    insert into MoneyAlert.StatusChangePushMessage
	--    values
	--    (@Claimcode,getdate(),null,0)
	--End Try                                                                                            
	--Begin Catch
	-- Declare @ErrorMessage nvarchar(max)                                                                                             
	-- Select @ErrorMessage=ERROR_MESSAGE()                                             
	-- Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ResponseReturnCode',Getdate(),@ErrorMessage)                                                                                            
	--End Catch  
		End

	

	End
	Else
	Begin
		Select @Description='Return code UNKNOWN:'+@ReturnCode+' '+@str
		Exec st_SimpleAddNoteToTransfer  @IdTransfer,@Description
	End
	Set @IsCorrect=1
	--If @IdStatusAction>0  and @ActualIdStatus<>@IdStatusAction                              
	--Begin                                
	--	if @IdTransfer is not null                          
	--	begin                               
	--		Update Transfer set IdStatus=@IdStatusAction,DateStatusChange=GETDATE() where IdTransfer=@IdTransfer                                
	--		Exec st_SaveChangesToTransferLog @IdTransfer,@IdStatusAction,@Description,0             
	--	If @IdStatusAction=31 --- Rejected balance            
	--	Begin            
	--		Exec st_RejectedCreditToAgentBalance @IdTransfer            
	--	End             
	--	If @IdStatusAction=22  -- Cancel Balance            
	--	Begin  
	--			If not exists(Select 1 from TransfersUnclaimed where IdTransfer=@IdTransfer and IdStatus=1)	                                                     
	--				Exec st_CancelCreditToAgentBalance @IdTransfer 
	--			Else                   
	--			Begin
	--				Declare @UnclaimedStatus int 
	--				set @UnclaimedStatus=27
	--				Update TransfersUnclaimed set IdStatus=2 where IdTransfer=@IdTransfer
	--				Update Transfer set IdStatus=@UnclaimedStatus,DateStatusChange=GETDATE() where IdTransfer=@IdTransfer  
	--				Exec st_SaveChangesToTransferLog @IdTransfer,@UnclaimedStatus,@Description,0
	--			End
	--	End                                         
	-- End                          
	--End                  
	--Else                  
	--Begin                  
	--	Select @Description='Return code UNKNOWN:'+@ReturnCode+' '+@str                  
	--	Exec st_SimpleAddNoteToTransfer  @IdTransfer,@Description                  
	--End                  
	--Set @IsCorrect=1
END TRY
BEGIN CATCH
	Set @IsCorrect=1
	Declare @ErrorMessage nvarchar(max)                                                                                             
	Select @ErrorMessage=ERROR_MESSAGE()                                             
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ResponseReturnCodeGirosLatinos',Getdate(),@ErrorMessage)                                                                                            
END CATCH