CREATE PROCEDURE st_SaveAgentPosMerchant
(
	@IdAgentPosAccount			INT, 
                
	@IdAgentPosMerchant			INT, 
	@MerchantId					VARCHAR(100), 
	@IdGenericStatus			INT, 
	@IdUser						INT, 

	@HasError					BIT OUT,
    @Message					VARCHAR(MAX) OUT,
	@IdRecord					INT OUT
)
AS
BEGIN 

	IF EXISTS (SELECT 1 FROM AgentPosMerchant apm WITH(NOLOCK) WHERE apm.MerchantId = @MerchantId AND apm.IdAgentPosMerchant <> @IdAgentPosMerchant)
		SET @Message = CONCAT('The merchant id (', @MerchantId ,') already exists')

	SET @HasError = IIF(ISNULL(@Message, '') <> '', 1, 0)
	IF @HasError = 1
		RETURN


	BEGIN TRANSACTION
	BEGIN TRY
		IF ISNULL(@IdAgentPosMerchant, 0) > 0
		BEGIN
			UPDATE AgentPosMerchant SET
				MerchantId = @MerchantId,
				IdGenericStatus = @IdGenericStatus
			WHERE IdAgentPosMerchant = @IdAgentPosMerchant

			SET @IdRecord = @IdAgentPosMerchant
		END
		ELSE
		BEGIN
			INSERT INTO AgentPosMerchant(IdAgentPosAccount, MerchantId, IdGenericStatus, CreationDate, IdUser)
			VALUES (@IdAgentPosAccount, @MerchantId, @IdGenericStatus, GETDATE(), @IdUser)

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
		VALUES('st_SaveAgentPosMerchant', GETDATE(), @MSG_ERROR);
	END CATCH

END
