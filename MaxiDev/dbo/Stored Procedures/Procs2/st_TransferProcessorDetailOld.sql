CREATE Procedure [dbo].[st_TransferProcessorDetailOld](@IdTransfer int, @IdTransferStatus int) AS  
Set nocount on  
  
Declare @EnterByIdUser int  
Declare @IdUserType Int  
Declare @IdAgent int  
Declare @IdAgentStatus int  
Declare @IdPayer int  
Declare @OFAC int  
Declare @CustomerName nvarchar(max)  
Declare @CustomerFirstLastName nvarchar(max)  
Declare @CustomerSecondLastName nvarchar(max)  
Declare @BeneficiaryName nvarchar(max)  
Declare @BeneficiaryFirstLastName nvarchar(max)
Declare @BeneficiarySecondLastName nvarchar(max)   
Declare @IdPaymentType int  
--Cambios para ofac transfer detail
Declare @IsOFAC bit
Declare @IsOFACDoubleVerification bit
  
Select @EnterByIdUser=EnterByIdUser,  
  @IdAgent=IdAgent,  
  @IdPayer=IdPayer,  
  @CustomerName=CustomerName,  
  @CustomerFirstLastName=CustomerFirstLastName,
   @BeneficiaryName=BeneficiaryName,  
  @BeneficiaryFirstLastName=BeneficiaryFirstLastName,  
  @IdPaymentType=IdPaymentType,
  @CustomerSecondLastName=isnull(CustomerSecondLastName,''),
  @BeneficiarySecondLastName=isnull(BeneficiarySecondLastName,'')  
from Transfer where IdTransfer=@IdTransfer  
  
Set @OFAC=0  
  
Declare @IdUserSystem int  
Select @IdUserSystem = [Value] from GlobalAttributes where Name = 'SystemUserID'  
  
  
If @IdTransferStatus = 1  
Begin  
set @IsOFAC = 0
        set @IsOFACDoubleVerification=0

 Exec st_SaveChangesToTransferLog @IdTransfer,41,'Verify Hold',0 --- Log de validación de Multiholds  
 Update Transfer Set IdStatus=41,DateStatusChange=GETDATE() Where IdTransfer=@IdTransfer  
  
 --- Signature validation .. Phone verification  
  Exec st_SaveChangesToTransferLog @IdTransfer,2,'Signature Validation',0 --- Log de validacion  
  Select @IdUserType=IdUserType from Users Where IdUser=@EnterByIdUser  
  If @IdUserType=2 and Not exists(Select 1 from AgentUser where IdUser=@EnterByIdUser)-- usuario Multiagente--  
  Begin  
   Insert Into [dbo].[TransferHolds]([IdTransfer],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
   Values(@IdTransfer,3,GETDATE(),GETDATE() ,@IdUserSystem)  
   Exec st_SaveChangesToTransferLog @IdTransfer,3,'Signature Hold',0 -- Log , se ha detenido en signature hold  
  End  
   
 --- Agent Verification  
  Exec st_SaveChangesToTransferLog @IdTransfer,5,'AR Validation',0 --- Log de validacion  
  Select @IdAgentStatus=IdAgentStatus from Agent where IdAgent=@IdAgent  
  If (@IdAgentStatus=4) or (@IdAgentStatus=3) or (@IdAgentStatus=5)  or (@IdAgentStatus=7)
  Begin  
   Insert Into [dbo].[TransferHolds]([IdTransfer],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
   Values(@IdTransfer,6,GETDATE(),GETDATE() ,@IdUserSystem)  
   Exec st_SaveChangesToTransferLog @IdTransfer,6,'AR Hold',0 -- Log , se ha detenido en AR hold  
  End  
 --- KYC Verification ..  
  Exec st_SaveChangesToTransferLog @IdTransfer,8,'KYC Validation',0 --- Log de KYC validacion  
  If exists (Select 1 from BrokenRulesByTransfer where IdTransfer=@IdTransfer and IsDenyList=0) --AND ([dbo].[fun_GetIfInsertKycBasedOnRequestId](@IdTransfer) = 1)  
  Begin     
   DECLARE @isHolded as bit, @infoMessage as NVARCHAR(255)  
  
   SELECT @isHolded = isHolded, @infoMessage = infoMeesage  
   FROM [dbo].[fun_GetIfInsertKycBasedOnRequestId](@IdTransfer)  
  
   --Insert log  
   Exec st_SaveChangesToTransferLog @IdTransfer, 8, @infoMessage,0  
   IF(@isHolded = 1)  
    BEGIN       
     Insert Into [dbo].[TransferHolds]([IdTransfer],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
     Values(@IdTransfer,9,GETDATE(),GETDATE() ,@IdUserSystem)  
     Exec st_SaveChangesToTransferLog @IdTransfer,9,'KYC Hold',0 -- Log , se ha detenido en KYC Hold hold  
    END     
  End  
 --- DenyList Verification ..  
  Exec st_SaveChangesToTransferLog @IdTransfer,11,'Deny List Verification',0 --- Log de DenyList validacion  
  If exists (Select 1 from BrokenRulesByTransfer where IdTransfer=@IdTransfer and IsDenyList=1)  
  Begin  
   Insert Into [dbo].[TransferHolds]([IdTransfer],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
   Values(@IdTransfer,12,GETDATE(),GETDATE() ,@IdUserSystem)  
   Exec st_SaveChangesToTransferLog @IdTransfer,12,'Deny List Hold',0 -- Log , se ha detenido en DenyList Hold hold  
  End  
 --- OFAC validation ..  
  Exec st_SaveChangesToTransferLog @IdTransfer,14,'OFAC Verification',0 --- Log de OFAC validacion  
  
  --Cambios para ofac transfer detail
           EXEC	[dbo].[st_SaveTransferOFACInfo]
		        @IdTransfer = @IdTransfer,		        
		        @CustomerName = @CustomerName,
		        @CustomerFirstLastName = @CustomerFirstLastName,
		        @CustomerSecondLastName = @CustomerSecondLastName,		        
		        @BeneficiaryName = @BeneficiaryName,
		        @BeneficiaryFirstLastName = @BeneficiaryFirstLastName,
		        @BeneficiarySecondLastName = @BeneficiarySecondLastName,
                @IsOLDTransfer = 0,
                @IsOFAC =  @IsOFAC out,
                @IsOFACDoubleVerification =  @IsOFACDoubleVerification out          

          --If @OFAC<>0  
          If (@IsOFAC=1)
          Begin  
           Insert Into [dbo].[TransferHolds]([IdTransfer],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
                Values(@IdTransfer,15,GETDATE(),GETDATE() ,@IdUserSystem)  
           Exec st_SaveChangesToTransferLog @IdTransfer,15,'OFAC Hold',0 -- Log , se ha detenido en OFAC Hold  
           
           --Cambio para doble verificacion
           if (@IsOFACDoubleVerification=1)
           begin
            Insert Into [dbo].[TransferHolds]([IdTransfer],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
                Values(@IdTransfer,15,GETDATE(),GETDATE() ,@IdUserSystem)  
            Exec st_SaveChangesToTransferLog @IdTransfer,15,'OFAC Hold',0 -- Log , se ha detenido en OFAC Hold  
           end
          
          End  


 --- Deposit Verification ..  
  Exec st_SaveChangesToTransferLog @IdTransfer,17,'Deposit Verification',0 --- Log de Deposit validacion  
  If exists (Select 1 from PayerConfig where IdPayer=@IdPayer And DepositHold=1 And IdPaymentType=@IdPaymentType)  
  Begin  
   Insert Into [dbo].[TransferHolds]([IdTransfer],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
   Values(@IdTransfer,18,GETDATE(),GETDATE() ,@IdUserSystem)  
   Exec st_SaveChangesToTransferLog @IdTransfer,18,'Deposit Hold',0 -- Log , se ha detenido en Deposit Hold  
  End  
End  
  
If not exists (select top 1 IdTransferHold from TransferHolds where IdTransfer = @IdTransfer and (IsReleased is null or IsReleased=0)) --Si no existe un Hold sin evaluar o Rejected cambiar Status a 20  
Begin  

 declare @idsUpdated table
 (
     IdStatus int    
 )
 
 Update Transfer Set IdStatus=20,DateStatusChange=GETDATE()
 OUTPUT    
        INSERTED.IdStatus
 INTO 
    @idsUpdated 
 Where 
    IdTransfer=@IdTransfer and idstatus=41

 if exists (select top 1 IdStatus from @idsUpdated)
 begin
    Exec st_SaveChangesToTransferLog @IdTransfer,20,'Stand By',0 -- Log , En Ready to be taken by Gateway  
    declare @IsSpanishLanguage bit  
    declare @HasError bit  
    declare @Message nvarchar(max)  
    Exec st_DismissComplianceNotificationByIdTransfer @IdTransfer, @IsSpanishLanguage, @HasError out, @Message out  
 end

End  
  

/*
ALTER Procedure [dbo].[st_TransferProcessorDetailOld](@IdTransfer int, @IdTransferStatus int) AS  
Set nocount on  
  
Declare @EnterByIdUser int  
Declare @IdUserType Int  
Declare @IdAgent int  
Declare @IdAgentStatus int  
Declare @IdPayer int  
Declare @OFAC int  
Declare @CustomerName nvarchar(max)  
Declare @CustomerFirstLastName nvarchar(max)  
Declare @CustomerSecondLastName nvarchar(max)  
Declare @BeneficiaryName nvarchar(max)  
Declare @BeneficiaryFirstLastName nvarchar(max)
Declare @BeneficiarySecondLastName nvarchar(max)   
Declare @IdPaymentType int  
  
Select @EnterByIdUser=EnterByIdUser,  
  @IdAgent=IdAgent,  
  @IdPayer=IdPayer,  
  @CustomerName=CustomerName,  
  @CustomerFirstLastName=CustomerFirstLastName,
   @BeneficiaryName=BeneficiaryName,  
  @BeneficiaryFirstLastName=BeneficiaryFirstLastName,  
  @IdPaymentType=IdPaymentType,
  @CustomerSecondLastName=isnull(CustomerSecondLastName,''),
  @BeneficiarySecondLastName=isnull(BeneficiarySecondLastName,'')  
from Transfer where IdTransfer=@IdTransfer  
  
Set @OFAC=0  
  
Declare @IdUserSystem int  
Select @IdUserSystem = [Value] from GlobalAttributes where Name = 'SystemUserID'  
  
  
If @IdTransferStatus = 1  
Begin  
 Exec st_SaveChangesToTransferLog @IdTransfer,41,'Verify Hold',0 --- Log de validación de Multiholds  
 Update Transfer Set IdStatus=41,DateStatusChange=GETDATE() Where IdTransfer=@IdTransfer  
  
 --- Signature validation .. Phone verification  
  Exec st_SaveChangesToTransferLog @IdTransfer,2,'Signature Validation',0 --- Log de validacion  
  Select @IdUserType=IdUserType from Users Where IdUser=@EnterByIdUser  
  If @IdUserType=2 and Not exists(Select 1 from AgentUser where IdUser=@EnterByIdUser)-- usuario Multiagente--  
  Begin  
   Insert Into [dbo].[TransferHolds]([IdTransfer],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
   Values(@IdTransfer,3,GETDATE(),GETDATE() ,@IdUserSystem)  
   Exec st_SaveChangesToTransferLog @IdTransfer,3,'Signature Hold',0 -- Log , se ha detenido en signature hold  
  End  
   
 --- Agent Verification  
  Exec st_SaveChangesToTransferLog @IdTransfer,5,'AR Validation',0 --- Log de validacion  
  Select @IdAgentStatus=IdAgentStatus from Agent where IdAgent=@IdAgent  
  If (@IdAgentStatus=4) or (@IdAgentStatus=3) or (@IdAgentStatus=5)  or (@IdAgentStatus=7)
  Begin  
   Insert Into [dbo].[TransferHolds]([IdTransfer],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
   Values(@IdTransfer,6,GETDATE(),GETDATE() ,@IdUserSystem)  
   Exec st_SaveChangesToTransferLog @IdTransfer,6,'AR Hold',0 -- Log , se ha detenido en AR hold  
  End  
 --- KYC Verification ..  
  Exec st_SaveChangesToTransferLog @IdTransfer,8,'KYC Validation',0 --- Log de KYC validacion  
  If exists (Select 1 from BrokenRulesByTransfer where IdTransfer=@IdTransfer and IsDenyList=0) --AND ([dbo].[fun_GetIfInsertKycBasedOnRequestId](@IdTransfer) = 1)  
  Begin     
   DECLARE @isHolded as bit, @infoMessage as NVARCHAR(255)  
  
   SELECT @isHolded = isHolded, @infoMessage = infoMeesage  
   FROM [dbo].[fun_GetIfInsertKycBasedOnRequestId](@IdTransfer)  
  
   --Insert log  
   Exec st_SaveChangesToTransferLog @IdTransfer, 8, @infoMessage,0  
   IF(@isHolded = 1)  
    BEGIN       
     Insert Into [dbo].[TransferHolds]([IdTransfer],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
     Values(@IdTransfer,9,GETDATE(),GETDATE() ,@IdUserSystem)  
     Exec st_SaveChangesToTransferLog @IdTransfer,9,'KYC Hold',0 -- Log , se ha detenido en KYC Hold hold  
    END     
  End  
 --- DenyList Verification ..  
  Exec st_SaveChangesToTransferLog @IdTransfer,11,'Deny List Verification',0 --- Log de DenyList validacion  
  If exists (Select 1 from BrokenRulesByTransfer where IdTransfer=@IdTransfer and IsDenyList=1)  
  Begin  
   Insert Into [dbo].[TransferHolds]([IdTransfer],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
   Values(@IdTransfer,12,GETDATE(),GETDATE() ,@IdUserSystem)  
   Exec st_SaveChangesToTransferLog @IdTransfer,12,'Deny List Hold',0 -- Log , se ha detenido en DenyList Hold hold  
  End  
 --- OFAC validation ..  
  Exec st_SaveChangesToTransferLog @IdTransfer,14,'OFAC Verification',0 --- Log de OFAC validacion  
  Select @OFAC=( dbo.fun_OfacSearch (@CustomerName,@CustomerFirstLastName,@CustomerSecondLastName))+( dbo.fun_OfacSearch (@BeneficiaryName,@BeneficiaryFirstLastName,@BeneficiarySecondLastName))  
  If @OFAC<>0  
  Begin  
   Insert Into [dbo].[TransferHolds]([IdTransfer],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
   Values(@IdTransfer,15,GETDATE(),GETDATE() ,@IdUserSystem)  
   Exec st_SaveChangesToTransferLog @IdTransfer,15,'OFAC Hold',0 -- Log , se ha detenido en OFAC Hold  
  End  
 --- Deposit Verification ..  
  Exec st_SaveChangesToTransferLog @IdTransfer,17,'Deposit Verification',0 --- Log de Deposit validacion  
  If exists (Select 1 from PayerConfig where IdPayer=@IdPayer And DepositHold=1 And IdPaymentType=@IdPaymentType)  
  Begin  
   Insert Into [dbo].[TransferHolds]([IdTransfer],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
   Values(@IdTransfer,18,GETDATE(),GETDATE() ,@IdUserSystem)  
   Exec st_SaveChangesToTransferLog @IdTransfer,18,'Deposit Hold',0 -- Log , se ha detenido en Deposit Hold  
  End  
End  
  
If not exists (select top 1 IdTransferHold from TransferHolds where IdTransfer = @IdTransfer and (IsReleased is null or IsReleased=0)) --Si no existe un Hold sin evaluar o Rejected cambiar Status a 20  
Begin  

 declare @idsUpdated table
 (
     IdStatus int    
 )
 
 Update Transfer Set IdStatus=20,DateStatusChange=GETDATE()
 OUTPUT    
        INSERTED.IdStatus
 INTO 
    @idsUpdated 
 Where 
    IdTransfer=@IdTransfer and idstatus=41

 if exists (select top 1 IdStatus from @idsUpdated)
 begin
    Exec st_SaveChangesToTransferLog @IdTransfer,20,'Stand By',0 -- Log , En Ready to be taken by Gateway  
    declare @IsSpanishLanguage bit  
    declare @HasError bit  
    declare @Message nvarchar(max)  
    Exec st_DismissComplianceNotificationByIdTransfer @IdTransfer, @IsSpanishLanguage, @HasError out, @Message out  
 end

End  
  
*/