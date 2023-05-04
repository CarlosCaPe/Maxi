CREATE procedure [dbo].[st_ResponseReturnCodeBancoIndustrial]
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
<Author>Not Known</Author>
<app>MaxiService</app>
<Description></Description>

<ChangeLog>
<log Date="11/09/2018" Author="jmolina">Add with(nolock) And cast to @ReturnCode #1</log>
</ChangeLog>
********************************************************************/
Set nocount on 
BEGIN TRY                                       
	Declare @Description nvarchar(max)                                          
	Declare @IdStatusAction int                                          
	Declare @IdTransfer int                                          
	Declare @ActualIdStatus Int
	Declare @str varchar(max)
	declare @ReturnAllComission int
	DECLARE @ReturnCodeS nvarchar(32)--#1
	declare @ClaimcodeCast nvarchar(50)

	set @str=''
	set @ClaimcodeCast = convert(nvarchar(50), @Claimcode)

	SET @ReturnCodeS = CONVERT(nvarchar(32), @ReturnCode) --#1
                                          
	Select @IdStatusAction=A.IdStatusAction,@Description=B.ReturnCodeType+' code '+@ReturnCodeS+','+[Description]
	from GatewayReturnCode As A WITH(NOLOCK)
	inner Join GatewayReturnCodeType AS B WITH(NOLOCK)  on (A.IdGatewayReturnCodeType=B.IdGatewayReturnCodeType)   
	where A.IdGateway=@IdGateway And A.IdGatewayReturnCodeType=@ReturnCodeType And A.ReturnCode=@ReturnCodeS --@ReturnCode --#1
                                          
	Insert into BancoIndustrialResponseLog values (getdate(),@Claimcode,@ReturnCode,@ReturnCodeType,@IdStatusAction,@Description,@XmlValue)                      
                  
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
	Select @IdTransfer=IdTransfer from [transfer] WITH(NOLOCK) where claimcode = @ClaimcodeCast --@Claimcode --#1

	Select @ActualIdStatus=IdStatus,
		   @ReturnAllComission=ReturnAllComission 
	From [Transfer] AS t WITH(NOLOCK)
	left join 
		ReasonForCancel AS r WITH(NOLOCK) on t.IdReasonForCancel=r.IdReasonForCancel
	where IdTransfer=@IdTransfer   

	--Validar razon de cancelacion
	set @ReturnAllComission=isnull(@ReturnAllComission,0)                                    
                            
	If @IdStatusAction>0           
	Begin                                            
		if @IdTransfer is not null and @ActualIdStatus<>@IdStatusAction                                                                       
		Begin                                           
			Update [Transfer] set IdStatus=@IdStatusAction,DateStatusChange=GETDATE() where IdTransfer=@IdTransfer                                            
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
					Update [Transfer] set IdStatus=@UnclaimedStatus,DateStatusChange=GETDATE() where IdTransfer=@IdTransfer  
					Exec st_SaveChangesToTransferLog @IdTransfer,@UnclaimedStatus,@Description,0
				End
			End
			If @IdStatusAction=30  -- Paid
			Begin
				exec st_SavePayInfoBancoIndustrial @IdGateway,@IdTransfer,@Claimcode,@XmlValue
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
			--Begin Try 
		 --        insert into MoneyAlert.StatusChangePushMessage
		 --        values (@Claimcode,getdate(),null,0)
	  --      End Try                                                                                            
	  --    Begin Catch
	  --          Declare @ErrorMessage nvarchar(max)                                                                                             
	  --          Select @ErrorMessage=ERROR_MESSAGE()                                             
	  --          Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ResponseReturnCodeBancoIndustrial',Getdate(),@ErrorMessage)
	  --    End Catch  
		                                                    
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
	 Declare @ErrorMessage nvarchar(max)                                                                                             
	 Select @ErrorMessage=ERROR_MESSAGE()                                             
	 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ResponseReturnCodeBancoIndustrial',Getdate(),@ErrorMessage)
END CATCH