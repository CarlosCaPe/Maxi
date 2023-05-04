CREATE PROCEDURE st_SaveAgentPosAccount
(
	@IdAgentPosAccount			INT,
	@IdAgent					INT,
	@AccountNumber				VARCHAR(100),
	@IdGenericStatus			INT,
	@IdUser						INT,

	@HasError					BIT OUT,
    @Message					VARCHAR(MAX) OUT,
	@IdRecord					INT OUT
)
AS
BEGIN 

	IF EXISTS (SELECT 1 FROM AgentPosAccount apa  WITH(NOLOCK) WHERE apa.AccountNumber = @AccountNumber AND apa.IdAgentPosAccount <> @IdAgentPosAccount)
		SET @Message = CONCAT('The account number (', @AccountNumber, ') already exists')

	SET @HasError = IIF(ISNULL(@Message, '') <> '', 1, 0)
	IF @HasError = 1
		RETURN


	BEGIN TRANSACTION
	BEGIN TRY
		IF ISNULL(@IdAgentPosAccount, 0) > 0
		BEGIN
			UPDATE AgentPosAccount SET
				AccountNumber = @AccountNumber,
				IdGenericStatus = @IdGenericStatus
			WHERE IdAgentPosAccount = @IdAgentPosAccount

			SET @IdRecord = @IdAgentPosAccount
		END
		ELSE
		BEGIN
			INSERT INTO AgentPosAccount(IdAgent, AccountNumber, IdGenericStatus, CreationDate, IdUser)
			VALUES (@IdAgent, @AccountNumber, @IdGenericStatus, GETDATE(), @IdUser)

			SET @IdRecord = @@identity
		END

		SET @HasError = 0
		SET @Message = NULL
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @MSG_ERROR NVARCHAR(500) = ERROR_MESSAGE();

		SET @HasError = 1
		SET @Message = 'Error when saving'

		INSERT INTO ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage)
		VALUES('st_SaveAgentPosAccount', GETDATE(), @MSG_ERROR);
	END CATCH

END
