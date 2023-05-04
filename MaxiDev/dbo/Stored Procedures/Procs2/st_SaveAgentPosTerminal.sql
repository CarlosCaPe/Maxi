CREATE PROCEDURE st_SaveAgentPosTerminal
(
	@IdAgentPosTerminal         INT,
	@IdAgentPosMerchant         INT,
	@IdPosTerminal              INT,
	@IP							VARCHAR(100),
	@Port                       VARCHAR(100),
	@IdGenericStatus            INT,
	@IdUser                     INT,

	@HasError					BIT OUT,
    @Message					VARCHAR(MAX) OUT,
	@IdRecord					INT OUT
)
AS
BEGIN 

	IF EXISTS (SELECT 1 FROM AgentPosTerminal apt WITH(NOLOCK) WHERE apt.IdPosTerminal = @IdPosTerminal AND IdAgentPosMerchant <> @IdAgentPosMerchant AND apt.IdGenericStatus = 1)
		SET @Message = 'The selected merchant already has an assigned terminal'

	SET @HasError = IIF(ISNULL(@Message, '') <> '', 1, 0)
	IF @HasError = 1
		RETURN

	IF ISNULL(@IdAgentPosTerminal, 0) = 0
	BEGIN
		SELECT 
			@IdAgentPosTerminal = apt.IdAgentPosTerminal,
			@IdGenericStatus = 1
		FROM AgentPosTerminal apt 
		WHERE apt.IdAgentPosMerchant = @IdAgentPosMerchant
			AND apt.IdPosTerminal = @IdPosTerminal
	END
			
	BEGIN TRANSACTION
	BEGIN TRY
		IF ISNULL(@IdAgentPosTerminal, 0) > 0
		BEGIN
			UPDATE AgentPosTerminal SET
				IP = @IP,
				Port = @Port,
				IdGenericStatus = @IdGenericStatus
			WHERE IdAgentPosTerminal = @IdAgentPosTerminal

			SET @IdRecord = @IdAgentPosTerminal
		END
		ELSE
		BEGIN
			INSERT INTO AgentPosTerminal(IdPosTerminal, IdAgentPosMerchant, IP, Port, IdGenericStatus, CreationDate, IdUser)
			VALUES (@IdPosTerminal, @IdAgentPosMerchant, @IP, @Port, @IdGenericStatus, GETDATE(), @IdUser)

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
		VALUES('st_SaveAgentPosTerminal', GETDATE(), @MSG_ERROR);
	END CATCH

END
