CREATE PROCEDURE st_InsertSpecialCommissionBalanceExternal
(
	@IdAgent			INT,
	@DateOfApplication	DATE,
	@Amount				MONEY,
	@IdExternalRule		INT,
	@Summary			VARCHAR(500),

	@IdUser				INT,

	@Success			BIT OUT,
	@ErrorMessage		VARCHAR(200) OUT,
	@IdSpecialCommissionBalance	INT OUT
)
AS
BEGIN
BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @IdSpecialCommisionRuleExternal INT

		SET @IdSpecialCommisionRuleExternal = CAST(dbo.GetGlobalAttributeByName('IdSpecialCommisionRuleExternal') AS INT)
		IF ISNULL(@IdSpecialCommisionRuleExternal, 0) = 0
			SET @IdSpecialCommisionRuleExternal = 1

		INSERT INTO SpecialCommissionBalance(IdAgent, DateOfMovement, Commission, IdSpecialCommissionRule, DateOfApplication)
		VALUES (@IdAgent, GETDATE(), @Amount, @IdSpecialCommisionRuleExternal, @DateOfApplication)

		SET @IdSpecialCommissionBalance = @@identity

		INSERT INTO SpecialCommissionBalanceExternal(IdSpecialCommissionBalance, IdExternalRule, Summary, EnterByIdUser)
		VALUES (@IdSpecialCommissionBalance, @IdExternalRule, @Summary, @IdUser)

		SELECT	@Success = 1,
				@ErrorMessage = NULL

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		SELECT	@Success = 0,
				@ErrorMessage = 'An unexpected error occurred while updating SpecialCommission'

		DECLARE @ExMessage VARCHAR(1000) = ERROR_MESSAGE()
		INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
		VALUES(OBJECT_NAME(@@PROCID), GETDATE(), @ExMessage)

	END CATCH
END