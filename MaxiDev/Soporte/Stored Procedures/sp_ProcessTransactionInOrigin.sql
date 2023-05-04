
-- =============================================
-- Author:		<Juan Diego Arellano>
-- Create date: <17 de julio de 2017>
-- Description:	<Procedimiento almacenado que procesa transferencias en estatus "Origin".>
-- =============================================
CREATE PROCEDURE [Soporte].[sp_ProcessTransactionInOrigin]
	@IdTransfer INT,
	@IsVisible BIT=0
AS
BEGIN
	Declare @IdTransferStatus int=1
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
	Declare @IdTransferResend int=0
	Declare @DateOfTransfer datetime
	Declare @StateTax money=0.00
	Declare @IsOFAC bit
	Declare @IsOFACDoubleVerification bit
	DECLARE @isHolded as bit, @infoMessage as NVARCHAR(255)  
	DECLARE @PercentMatchOfac1 float
	DECLARE @OFACHold bit = 0;
	DECLARE @AmountDlls MONEY = 0;

	Declare @IdUserSystem int  
			Select @IdUserSystem = [Value] from GlobalAttributes where Name = 'SystemUserID'

	if (@IsVisible=1)
	begin
		select * from Transfer(nolock)
		where IdTransfer=@IdTransfer

		select * from TransferDetail
		where IdTransfer=@IdTransfer

		select * from AgentBalance(nolock)
		where IdTransfer=@IdTransfer
	end
	 

	/*---------------------------------------------------------Mover Transacción de 'Origin'------------------------------------------------------------------------*/
	--[dbo].[sp_OriginMessageReader]
	if ((select 1 from Transfer(nolock) where IdTransfer=@IdTransfer and IdStatus=1)=1)
		begin
		if ((select top 1 1 from TransferDetail(nolock) where IdTransfer=@IdTransfer)=1)
		begin
			select 'El IdTransfer '+CONVERT(varchar,@IdTransfer)+' ya cuenta con registros en TransferDetail, favor de revisar'
			Return
		end

		else
		begin
			if ((select top 1 1 from AgentBalance(nolock) where IdTransfer=@IdTransfer)=1)
			begin
				
				Exec st_SaveChangesToTransferLog @IdTransfer,1,'Transfer Charge Added to Agent Balance',0,1

				select @IdAgent=idagent, @IdPayer=IdPayer, @CustomerName=CustomerName,@CustomerFirstLastName=CustomerFirstLastName,@CustomerSecondLastName=CustomerSecondLastName,
					@BeneficiaryName=BeneficiaryName, @BeneficiaryFirstLastName=BeneficiaryFirstLastName,@BeneficiarySecondLastName=BeneficiarySecondLastName,@IdPaymentType=IdPaymentType,
					@Amount=AmountInDollars,@Reference=Folio,@DateOfTransfer=DateOfTransfer, @EnterByIdUser=EnterByIdUser--,@IdTransferStatus=IdStatus
				from Transfer with(nolock) where IdTransfer=@IdTransfer

				

				set @IsOFAC = 0
				set @IsOFACDoubleVerification=0

			 
  
						If @IdTransferStatus = 1-->  
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

						  /*S09:Requerimiento_013017-2*/ 
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
							SET @AmountDlls = ISNULL((SELECT TOP 1 AmountInDollars FROM Transfer WITH(NOLOCK)WHERE IdTransfer = @IdTransfer),0);

 							IF ((@AmountDlls<200) AND (@PercentMatchOfac1 <95))
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

					if (@IsVisible=1)
					begin
						select * from Transfer(nolock)
						where IdTransfer=@IdTransfer

						select * from TransferDetail
						where IdTransfer=@IdTransfer

						select * from AgentBalance(nolock)
						where IdTransfer=@IdTransfer
					end
			end

			else 
			begin
			/*---------------------------------------------------------Mover Transacción de 'Origin'------------------------------------------------------------------------*/
			--[dbo].[sp_OriginMessageReader]
				
				select @IdAgent=idagent, @IdPayer=IdPayer, @CustomerName=CustomerName,@CustomerFirstLastName=CustomerFirstLastName,@CustomerSecondLastName=CustomerSecondLastName,
					@BeneficiaryName=BeneficiaryName, @BeneficiaryFirstLastName=BeneficiaryFirstLastName,@BeneficiarySecondLastName=BeneficiarySecondLastName,@IdPaymentType=IdPaymentType,
					@Amount=AmountInDollars,@Reference=Folio,@DateOfTransfer=DateOfTransfer, @EnterByIdUser=EnterByIdUser
				from Transfer with(nolock) where IdTransfer=@IdTransfer

				set @IsOFAC = 0
						set @IsOFACDoubleVerification=0

			  
						If @IdTransferStatus = 1-->  
						Begin    
						 --- Signature validation .. Phone verification 
						  Exec st_SaveChangesToTransferLog @IdTransfer,1,'Transfer Charge Added to Agent Balance',0,1 
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


							SET @AmountDlls = ISNULL((SELECT TOP 1 AmountInDollars FROM Transfer WITH(NOLOCK)WHERE IdTransfer = @IdTransfer),0);

 							IF ((@AmountDlls<200) AND (@PercentMatchOfac1 <95))
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

			/*-------------------------------------Afectar balance----------------------------------------------------------------------------*/


					Declare    @AmountAB Money       
					Declare    @Country nvarchar(max) 
					Declare    @AgentCommissionExtra money
					Declare    @AgentCommissionOriginal money
					Declare    @ModifierCommissionSlider money
					Declare    @ModifierExchangeRateSlider money


					select
						@IdTransfer=IdTransfer,
						@IdAgent=IdAgent,
						@AmountAB=TotalAmountToCorporate,
						@Reference=Folio,
						@CustomerName=CustomerName,
						@CustomerFirstLastName=CustomerFirstLastName,
						@Country=(select c.CountryCode
									from Transfer t (nolock)
									join CountryCurrency cc on cc.IdCountryCurrency=t.IdCountryCurrency
									join Country c on c.IdCountry=cc.IdCountry
									where t.IdTransfer=@IdTransfer),
						@AgentCommissionExtra=AgentCommissionExtra,
						@AgentCommissionOriginal=AgentCommissionOriginal,
						@ModifierCommissionSlider=ModifierCommissionSlider,
						@ModifierExchangeRateSlider=ModifierExchangeRateSlider
					from
						Transfer(nolock)
					where 
						IdTransfer=@IdTransfer

					Declare         
						@DateOfMovement datetime,        
						@Description nvarchar(max),        
						@Commission money,        
						@FxFee money,      
						@Balance money
        
					Set @Balance=0        
        
					Select          
					 @DateOfMovement=DATEADD (SECOND , 1 , GETDATE() ),          
					 @Description=@CustomerName+' '+@CustomerFirstLastName,         
					 @Commission=@AgentCommissionExtra+@AgentCommissionOriginal,    
					 @FxFee=@ModifierCommissionSlider+@ModifierExchangeRateSlider  
 
					If not Exists (Select 1 from AgentCurrentBalance with(nolock) where IdAgent=@IdAgent) 
					begin          
					  Insert into AgentCurrentBalance (IdAgent,Balance) values (@IdAgent,@Balance)          
					end           
          
					 Update AgentCurrentBalance set Balance=Balance+@AmountAB,@Balance=Balance+@AmountAB where IdAgent=@IdAgent        
        
					Insert into AgentBalance         
					(        
					IdAgent,        
					TypeOfMovement,        
					DateOfMovement,        
					Amount,        
					Reference,        
					Description,        
					Country,        
					Commission,  
					FxFee,        
					DebitOrCredit,        
					Balance,        
					IdTransfer        
					)        
					Values        
					(        
					@IdAgent,        
					'TRAN',        
					@DateOfMovement,        
					@AmountAB,        
					@Reference,        
					@Description,        
					@Country,        
					@Commission,  
					@FxFee,         
					'Debit',        
					@Balance,        
					@IdTransfer        
					)

					--EXEC st_GetAgentCreditApproval @IdAgent

					 --Validar CurrentBalance
					exec st_AgentVerifyCreditLimit @IdAgent

					if (@IsVisible=1)
					begin
						select * from Transfer(nolock)
						where IdTransfer=@IdTransfer

						select * from TransferDetail
						where IdTransfer=@IdTransfer

						select * from AgentBalance(nolock)
						where IdTransfer=@IdTransfer
					end
			end
		end
	end

	else
	begin
		select 'El IdTransfer '+CONVERT(varchar,@IdTransfer)+' no existe o no se encuentra en "Origin", favor de verificar el ID correcto y/o Status'
		Return
	end
END
