CREATE  procedure [dbo].[st_ResponseReturnCodeInpamex]                                
(                                
    @IdGateway  int,                                
    @Claimcode  nvarchar(max),                                
    @ReturnCode nvarchar(max),                                
    @ReturnCodeType int,                           
    @XmlValue xml,                          
    @IsCorrect bit Output                          
)                           
AS                          
Set nocount on                
Declare @Message varchar(max)              
Declare @Description nvarchar(max)                            
Declare @IdStatusAction int                            
Declare @IdTransfer int,@ActualIdStatus int                            
Declare  @str varchar(max)  
declare @ReturnAllComission int    

IF  @IdGateway=25
BEGIN
    SET @IdGateway = 26
END        

set @str=''
              
Set @Message=''              
If @ReturnCode='1' and @ReturnCodeType=1              
Begin              
  Set @Message=CONVERT(varchar(max),@XmlValue)                
End              
                            
Select @IdStatusAction=IdStatusAction,@Description=Description+' '+@Message from GatewayReturnCode                             
where IdGateway=@IdGateway And IdGatewayReturnCodeType=@ReturnCodeType And ReturnCode=@ReturnCode                            
                            
Insert into   InpamexResponseLog values (getdate(),@Claimcode,@ReturnCode,@ReturnCodeType,@IdStatusAction,@Description,@XmlValue)                          
                      
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
   
--- Next if, is to control Cancel in process     
if (@ActualIdStatus=25 and @IdStatusAction=23)   
Begin  
 Set @ActualIdStatus=26  
End  
if (@ActualIdStatus=26 and @IdStatusAction=23)   
Begin  
 Set @IdStatusAction=26  
End                                        
          
--Validar razon de cancelacion
set @ReturnAllComission=isnull(@ReturnAllComission,0)          
                              
If @IdStatusAction>0                                              
Begin                                              
	if @IdTransfer is not null  and @ActualIdStatus<>@IdStatusAction                                      
	begin                                             
		Update Transfer set IdStatus=@IdStatusAction,DateStatusChange=GETDATE() where IdTransfer=@IdTransfer                                              
		Exec st_SaveChangesToTransferLog @IdTransfer,@IdStatusAction,@Description,0                           
		If @IdStatusAction=31 --- Rejected balance                          
		Begin                          
			Exec st_RejectedCreditToAgentBalance @IdTransfer                          
		End                           
		If @IdStatusAction=22  -- Cancel Balance                          
		Begin  
			If not exists(Select 1 from TransfersUnclaimed where IdTransfer=@IdTransfer and IdStatus=1)	                                                     
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
            exec st_SavePayInfoInpamex @IdGateway,@IdTransfer,@Claimcode,@XmlValue
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

		Begin Try 
    insert into MoneyAlert.StatusChangePushMessage
    values
    (@Claimcode,getdate(),null,0)
End Try                                                                                            
Begin Catch
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ResponseReturnCode',Getdate(),@ErrorMessage)                                                                                            
End Catch 

	End      
 
	                                                                               
End                                
Else                                
Begin                                
	Select @Description='Return code UNKNOWN:'+@ReturnCode+' '+@str                                
	Exec st_SimpleAddNoteToTransfer  @IdTransfer,@Description                                
End                                
Set @IsCorrect=1