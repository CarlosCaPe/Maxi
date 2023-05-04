CREATE   PROCEDURE [MoneyOrder].[st_UpdateConfigurationMoneyOrderAgent]
(
	@PIN VARCHAR(20),
	@TransactionFee MONEY,
	@IdGenericStatus INT,
	@TransactionFeeTop MONEY,
	@TransactionFeeBottom MONEY,
	@CommissionToAgent TINYINT,
	@VerifySequence BIT,
	@IdAgent INT,
	@IdLanguage INT,
	@EnterByIdUser INT,
	@HasError BIT OUT,
    @MessageOut NVARCHAR(MAX) OUT
)
AS
BEGIN
	DECLARE @MSG_ERROR NVARCHAR(500)

	BEGIN TRY
		IF  EXISTS (SELECT TOP 1 IdAgentRegistration FROM MoneyOrder.AgentRegistration WITH(NOLOCK) WHERE IdAgent = @IdAgent)
		BEGIN 
			UPDATE MoneyOrder.AgentRegistration 
			SET	PIN = @PIN,
				TransactionFee = @TransactionFee,
				IdGenericStatus = @IdGenericStatus,
				TransactionFeeTop = @TransactionFeeTop,
				TransactionFeeBottom = @TransactionFeeBottom,
				CommissionToAgent = @CommissionToAgent,
				VerifySequence = @VerifySequence,
				EnterByIdUser = @EnterByIdUser,
				DateOfLastChange = GETDATE()
			WHERE IdAgent = @IdAgent
		END
		ELSE 
		BEGIN
			INSERT INTO MoneyOrder.AgentRegistration (IdAgent,PIN,TransactionFee,IdGenericStatus,CreationDate,DateOfLastChange,EnterByIdUser,TransactionFeeTop,TransactionFeeBottom,CommissionToAgent,VerifySequence)
			VALUES (@IdAgent, @PIN, @TransactionFee, @IdGenericStatus, GETDATE(), GETDATE(), @EnterByIdUser, @TransactionFeeTop, @TransactionFeeBottom, @CommissionToAgent, @VerifySequence)
		END
		
		SET @HasError = 0
    	SELECT @MessageOut = dbo.GetMessageFromMultiLenguajeResorces (@IdLanguage,'GenericOkSave')
			
	END TRY
	BEGIN CATCH
		SET @HasError=1
		SELECT @MessageOut = dbo.GetMessageFromMultiLenguajeResorces (@IdLanguage,'GenericErrorSave')
		DECLARE @ErrorMessage NVARCHAR(MAX)
		SELECT @ErrorMessage=ERROR_MESSAGE()

		INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) 
		VALUES(ERROR_PROCEDURE() ,GETDATE(), @MSG_ERROR);
	END CATCH
END