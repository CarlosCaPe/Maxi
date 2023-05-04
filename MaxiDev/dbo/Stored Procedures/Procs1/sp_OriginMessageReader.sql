CREATE PROCEDURE [dbo].[sp_OriginMessageReader]
AS
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description>Reiniciar los Queues del ambiente correspondiente</Description>

<ChangeLog>
<log Date="19/06/2017" Author="snevarez">S26 :: This stored create notificacion </log>
<log Date="2019/08/13" Author="adominguez"> M00056 : Modificaiones</log>
</ChangeLog>
********************************************************************/															 
DECLARE
    @conversation uniqueidentifier,
    @senderMsgType nvarchar(100),
    @msg xml

Declare @IdTransfer int
Declare @IdTransferStatus int
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
Declare @Amount money
Declare @Reference int
Declare @Country nvarchar(max)
Declare @AgentCommissionExtra money
Declare @AgentCommissionOriginal money
Declare @ModifierCommissionSlider money
Declare @ModifierExchangeRateSlider money
Declare @IdTransferResend int
Declare @DateOfTransfer datetime
Declare @StateTax money
--Cambios para ofac transfer detail
Declare @IsOFAC bit
Declare @IsOFACDoubleVerification bit
declare @PendigByChangeRequetsStatus int
declare @OriginalIdStatus int

--Modificar Para cualquier ambiente 
--QA = 75
Set @PendigByChangeRequetsStatus = 72
Begin Try 

WAITFOR (
    RECEIVE TOP(1)
        @conversation=conversation_handle,
        @msg=message_body,
        @senderMsgType=message_type_name
    FROM QueueSW.OriginRecipQueue);

	    
    IF @senderMsgType = N'//Maxi/Transfer/OriginDataType'
    BEGIN
        SELECT @msg AS RecievedMessage,@senderMsgType AS SenderMessageType;

        set @IdTransfer = @msg.value('(OriginDataType/Transfer/IdTransfer)[1]', 'INT');
        set @IdTransferStatus = @msg.value('(OriginDataType/Transfer/IdTransferStatus)[1]', 'INT');
        set @EnterByIdUser = @msg.value('(OriginDataType/Transfer/EnterByIdUser)[1]', 'INT')        
        set @IdAgent = @msg.value('(OriginDataType/Transfer/IdAgent)[1]', 'INT')        
        set @IdPayer = @msg.value('(OriginDataType/Transfer/IdPayer)[1]', 'INT')        
        set @IdPaymentType = @msg.value('(OriginDataType/Transfer/IdPaymentType)[1]', 'INT')        
        set @CustomerName = @msg.value('(OriginDataType/Transfer/CustomerName)[1]', 'NVARCHAR(max)')
        set @CustomerFirstLastName = @msg.value('(OriginDataType/Transfer/CustomerFirstLastName)[1]', 'NVARCHAR(max)')
        set @CustomerSecondLastName = @msg.value('(OriginDataType/Transfer/CustomerSecondLastName)[1]', 'NVARCHAR(max)')
        set @BeneficiaryName = @msg.value('(OriginDataType/Transfer/BeneficiaryName)[1]', 'NVARCHAR(max)')
        set @BeneficiaryFirstLastName = @msg.value('(OriginDataType/Transfer/BeneficiaryFirstLastName)[1]', 'NVARCHAR(max)')
        set @BeneficiarySecondLastName = @msg.value('(OriginDataType/Transfer/BeneficiarySecondLastName)[1]', 'NVARCHAR(max)')
        set @Amount = @msg.value('(OriginDataType/Transfer/Amount)[1]', 'MONEY')
        set @Reference = @msg.value('(OriginDataType/Transfer/Reference)[1]', 'INT')
        set @Country = @msg.value('(OriginDataType/Transfer/Country)[1]', 'NVARCHAR(max)')
        set @AgentCommissionExtra= @msg.value('(OriginDataType/Transfer/AgentCommissionExtra)[1]', 'MONEY')
        set @AgentCommissionOriginal = @msg.value('(OriginDataType/Transfer/AgentCommissionOriginal)[1]', 'MONEY')
        set @ModifierCommissionSlider = @msg.value('(OriginDataType/Transfer/ModifierCommissionSlider)[1]', 'MONEY')
        set @ModifierExchangeRateSlider = @msg.value('(OriginDataType/Transfer/ModifierExchangeRateSlider)[1]', 'MONEY')
		set @IdTransferResend =@msg.value('(OriginDataType/Transfer/IdTransferResend)[1]', 'INT') 
		set @DateOfTransfer =@msg.value('(OriginDataType/Transfer/DateOfTransfer)[1]', 'DATETIME') 
		set @StateTax =@msg.value('(OriginDataType/Transfer/StateTax)[1]', 'MONEY') 


		--- Pending by change request by modify Verification ..
		if (exists (Select top 1 1 from TransferModify with(nolock) where NewIdTransfer = @IdTransfer and IsCancel = 0 and OldIdStatus <> 22) )
		Begin
			Exec st_SaveChangesToTransferLog @IdTransfer,@PendigByChangeRequetsStatus,'Pending by change request',0 --- Log de validación Pending by change request
			Update Transfer Set IdStatus=@PendigByChangeRequetsStatus,DateStatusChange=GETDATE() Where IdTransfer=@IdTransfer  
		End
		Else
		Begin
		----------------------  Insert in case Resend Transfer -------------------------------------------------------                                                                                                        
                                                                           
		If ISNULL(@IdTransferResend,0) <> 0                                                                                            
		Begin                     
			Insert into TransferResend (IdTransfer,Note,DateOfLastChange,EnterByIdUser,NewIdTransfer)                                
			values (@IdTransferResend,'Resend by st_CreateTransfer',@DateOfTransfer,@EnterByIdUser,@IdTransfer)                                                                                            
			-- Afectar el saldo del agente con un cargo negativo -----------                                                                 
			Declare @ReturnCommission money                                                                
			Declare @ResendHasError bit                                                                
			Declare @ResendMessage nvarchar(max)                                                                
			Declare @ReferenceResend nvarchar(max),@ResendNote nvarchar(max)     
  
			If Exists(Select 1 From Transfer with(nolock) where IdTransfer=@IdTransferResend)  
			Begin  
			 Select @ReturnCommission=case when TotalAmountToCorporate=AmountInDollars+Fee Then  (TotalAmountToCorporate-AmountInDollars) Else (CorporateCommission) End ,  
			 --@ResendNote='Credit Retransfer, Folio:'+CONVERT(varchar(max),Folio),   
			 @ResendNote='Folio:'+CONVERT(varchar(max),Folio),   
			 @ReferenceResend=CONVERT(varchar(max),Folio)   
			 From Transfer with(nolock) where IdTransfer=@IdTransferResend                                  
			End  
			Else  
			Begin   
			 Select @ReturnCommission=case when TotalAmountToCorporate=AmountInDollars+Fee Then  (TotalAmountToCorporate-AmountInDollars) Else (CorporateCommission) End ,  
			 --@ResendNote='Credit Retransfer, Folio:'+CONVERT(varchar(max),Folio),   
			 @ResendNote='Folio:'+CONVERT(varchar(max),Folio),   
			 @ReferenceResend=CONVERT(varchar(max),Folio)   
			 From TransferClosed with(nolock) where IdTransferClosed=@IdTransferResend                                
			End  
                               
			exec st_SaveOtherCharge 1,@IdAgent,@ReturnCommission,0,@DateOfTransfer,@ResendNote,@ReferenceResend,@EnterByIdUser,@HasError=@ResendHasError Output,@Message=@ResendMessage  Output,@IdOtherChargesMemo=6,@OtherChargesMemoNote=null   --6	Retransfer Credit
  
		End                                                                                        
                                                                    
		---------------------------- State Tax --------------------------------------------------------------------------                                                                    
		If @StateTax>0                                                                    
		Begin                                             
                   
		 Insert into StateFee (State,Tax,IdTransfer)                                                                    
		 Select AgentState,@StateTax,@IdTransfer from Agent with(nolock) Where IdAgent=@IdAgent                   
                  
		 Declare @FeeNote nvarchar(max), @FeeReference nvarchar(max), @SateName nvarchar(max),@StateFeeHasError bit,@StateFeeMessage nvarchar(max)                      
		 Select top 1 @SateName=StateName  from ZipCode with(nolock) where StateCode=(Select AgentState from Agent with(nolock) Where IdAgent=@IdAgent )                  
		 --Select @FeeNote=@SateName+' State Fee, Folio:'+CONVERT(varchar(max),Folio), @FeeReference=CONVERT(varchar(max),Folio) From Transfer where IdTransfer=@IdTransfer                                                  
		 Select @FeeNote='Folio:'+CONVERT(varchar(max),Folio), @FeeReference=CONVERT(varchar(max),Folio) From Transfer with(nolock) where IdTransfer=@IdTransfer                                                  
  
		 Exec st_SaveOtherCharge 1,@IdAgent,@StateTax,1,@DateOfTransfer,@FeeNote,@FeeReference,@EnterByIdUser,@HasError=@StateFeeHasError Output,@Message=@StateFeeMessage   Output,@IdOtherChargesMemo=1,@OtherChargesMemoNote=null   --1	Oklahoma State Fee
                                                                    
		End                                                                    

        /*Balance*/
        If @IdTransferStatus=1       
        Begin      
            Exec st_DebitToAgentBalanceForSB @IdTransfer,@IdAgent, @Amount, @Reference,@CustomerName,@CustomerFirstLastName,@Country,@AgentCommissionExtra,@AgentCommissionOriginal,@ModifierCommissionSlider,@ModifierExchangeRateSlider
	        Exec st_SaveChangesToTransferLog @IdTransfer,1,'Transfer Charge Added to Agent Balance',0,1    
        End 

        /*Hold Validations*/
        --Set @OFAC=0  
        --Cambios para ofac transfer detail
        set @IsOFAC = 0
        set @IsOFACDoubleVerification=0

        Declare @IdUserSystem int  
        Select @IdUserSystem = [Value] from GlobalAttributes where Name = 'SystemUserID'  
  
        If @IdTransferStatus = 1  
        Begin    
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
          If (@IdAgentStatus=4) or (@IdAgentStatus=3) or (@IdAgentStatus=5) or (@IdAgentStatus=7)
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
          
          --Select @OFAC=( dbo.fun_OfacSearch (@CustomerName,@CustomerFirstLastName,@CustomerSecondLastName))+( dbo.fun_OfacSearch (@BeneficiaryName,@BeneficiaryFirstLastName,@BeneficiarySecondLastName))  

		  DECLARE @PercentMatchOfac1 float /*S09:Requerimiento_013017-2*/ 
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
				,@PercentMatchOfac = @PercentMatchOfac1 out /*Requerimiento_013017-2*/ 

			/*Requerimiento_013017-2: Amount without Fee*/
			DECLARE @OFACHold bit = 0;
			DECLARE @AmountDlls MONEY = 0;
			SET @AmountDlls = ISNULL((SELECT TOP 1 AmountInDollars FROM Transfer WITH(NOLOCK)WHERE IdTransfer = @IdTransfer),0);

			DECLARE @AmountOfacValidation MONEY, @Percentage INT

			Select @AmountOfacValidation = [Value] from GlobalAttributes where Name = 'AmountOfacHoldValidation'  
			Select @Percentage = [Value] from GlobalAttributes where Name = 'PercentageOfacMatchHoldValidation'  

 			IF ((@AmountDlls<@AmountOfacValidation) AND (@PercentMatchOfac1 <@Percentage))
			BEGIN			
					SET @OFACHold = 1;
			END
			/**/

			IF(@OFACHold=0)/*S09:Requerimiento_013017-2*/
			BEGIN

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
			             
			END/*S09*/

           
         --- Deposit Verification ..  
          Exec st_SaveChangesToTransferLog @IdTransfer,17,'Deposit Verification',0 --- Log de Deposit validacion  
          If exists (Select 1 from PayerConfig where IdPayer=@IdPayer And DepositHold=1 And IdPaymentType=@IdPaymentType)  
          Begin  
           Insert Into [dbo].[TransferHolds]([IdTransfer],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
           Values(@IdTransfer,18,GETDATE(),GETDATE() ,@IdUserSystem)  
           Exec st_SaveChangesToTransferLog @IdTransfer,18,'Deposit Hold',0 -- Log , se ha detenido en Deposit Hold  
          End 

         Exec st_SaveChangesToTransferLog @IdTransfer,41,'Verify Hold',0 --- Log de validación de Multiholds  
         Update Transfer Set IdStatus=41,DateStatusChange=GETDATE() Where IdTransfer=@IdTransfer  

        End

		/*S26:Notificaciones Automaticas Transferencias KYC Hold*/
		Exec [dbo].[st_CreateComplianceNotificationCustomerRequestId] @IdTransfer;

        insert into dbo.SBReceiveOriginMessageLog (ConversationID,MessageXML,[IdTransfer]) values (@conversation,@msg,@IdTransfer)
        End
    END
     
END CONVERSATION @conversation;

End Try                                                                                            
Begin Catch
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('sp_OriginMessageReader',Getdate(),@ErrorMessage)                                                                                            
End Catch
