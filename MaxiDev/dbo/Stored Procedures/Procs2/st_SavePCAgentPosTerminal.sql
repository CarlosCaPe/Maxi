CREATE PROCEDURE st_SavePCAgentPosTerminal
(
	@IdAgentPosTerminal             INT,
                
	@IdPCAgentPosTerminal           INT,
	@IdPcIdentifier                 INT,
	@IdGenericStatus                INT,
	@IdUser                         INT,

	@HasError						BIT OUT,
    @Message						VARCHAR(MAX) OUT,
	@IdRecord						INT OUT
)
AS
BEGIN 

	IF EXISTS (SELECT 1 FROM PCAgentPosTerminal pc WITH(NOLOCK) WHERE pc.IdPcIdentifier = @IdPcIdentifier AND IdAgentPosTerminal <> @IdAgentPosTerminal AND pc.IdGenericStatus = 1)
		SET @Message = 'The selected computer already has a terminal assigned'

	SET @HasError = IIF(ISNULL(@Message, '') <> '', 1, 0)
	IF @HasError = 1
		RETURN


	BEGIN TRANSACTION
	BEGIN TRY
		IF ISNULL(@IdPCAgentPosTerminal, 0) > 0
		BEGIN
			UPDATE PCAgentPosTerminal SET
				IdGenericStatus = @IdGenericStatus
			WHERE IdPCAgentPosTerminal = @IdPCAgentPosTerminal

			SET @IdRecord = @IdPCAgentPosTerminal
		END
		ELSE
		BEGIN
			INSERT INTO PCAgentPosTerminal(IdPcIdentifier, IdAgentPosTerminal, IdGenericStatus, CreationDate, IdUser)
			VALUES (@IdPcIdentifier, @IdAgentPosTerminal, @IdGenericStatus, GETDATE(), @IdUser)

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
		VALUES('st_SavePCAgentPosTerminal', GETDATE(), @MSG_ERROR);
	END CATCH

END
