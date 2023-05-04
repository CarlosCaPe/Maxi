CREATE PROCEDURE MoneyOrder.st_SaveAgentMoneyOrderRegistration
(
	@IdAgent			INT,
	@PIN				VARCHAR(20),
	@GUID				VARCHAR(50),
	@PrivateKey			VARCHAR(3000),
	@PublicKey			VARCHAR(3000),
	@EffectiveStartDate	DATETIME,
	@EffectiveEndDate	DATETIME,
	@RouteCode			VARCHAR(50),
	@AccountNo			VARCHAR(50),
	@CompanyId			INT,
	@StoreId			INT,

	@EnterByIdUser		INT,
	@IdLanguage			INT
)
AS
BEGIN
	DECLARE @MSG_ERROR NVARCHAR(500)

	BEGIN TRY
		IF EXISTS(SELECT 1 FROM MoneyOrder.AgentRegistration ar WITH(NOLOCK) WHERE ar.IdAgent = @IdAgent)
			UPDATE MoneyOrder.AgentRegistration SET
				PIN = @PIN,
				[GUID] = @GUID,
				PrivateKey = @PrivateKey,
				PublicKey = @PublicKey,
				EffectiveStartDate = @EffectiveStartDate,
				EffectiveEndDate = @EffectiveEndDate,
				RouteCode = @RouteCode,
				AccountNo = @AccountNo,
				CompanyId = @CompanyId,
				StoreId = @StoreId,
				DateOfLastChange = GETDATE()
			WHERE IdAgent = @IdAgent
		ELSE
		BEGIN
			DECLARE @MODefaultTransactionFee DECIMAL
			SET @MODefaultTransactionFee = TRY_CAST(dbo.GetGlobalAttributeByName('MO_Default_TransactionFee') AS MONEY)
			SET @MODefaultTransactionFee = ISNULL(@MODefaultTransactionFee, 1)

			INSERT INTO MoneyOrder.AgentRegistration
			(
				IdAgent,
				PIN,
				TransactionFee,
				[GUID],
				PrivateKey,
				PublicKey,
				EffectiveStartDate,
				EffectiveEndDate,
				RouteCode,
				AccountNo,
				CompanyId,
				StoreId,
				IdGenericStatus,
				CreationDate,
				DateOfLastChange,
				EnterByIdUser
			)
			VALUES
			(
				@IdAgent,
				@PIN,
				@MODefaultTransactionFee,
				@GUID,
				@PrivateKey,
				@PublicKey,
				@EffectiveStartDate,
				@EffectiveEndDate,
				@RouteCode,
				@AccountNo,
				@CompanyId,
				@StoreId,
				1,
				GETDATE(),
				GETDATE(),
				@EnterByIdUser
			)
		END

		SELECT 
			1 Success,
			dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage,'GenericOkSave') [Message]
	END TRY
	BEGIN CATCH
		IF(ISNULL(@MSG_ERROR, '') = '')
			SET @MSG_ERROR = ERROR_MESSAGE();

		SELECT 
			0 Success,
			dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage,'GenericErrorSave') [Message]

		INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) 
		VALUES(ERROR_PROCEDURE() ,GETDATE(), @MSG_ERROR);
	END CATCH
END