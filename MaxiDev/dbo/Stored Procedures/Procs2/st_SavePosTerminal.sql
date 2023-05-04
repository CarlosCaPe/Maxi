CREATE PROCEDURE st_SavePosTerminal
(
	@IdPosTerminal				INT, 

	@TerminalId					VARCHAR(100), 
	@SerialNumber				VARCHAR(100), 
	@MAC						VARCHAR(100), 
	@DeviceType					VARCHAR(100), 
	@OSVersion					VARCHAR(100), 
	@IdAsset					VARCHAR(100), 
	@IdGenericStatus			INT, 
	@IdUser						INT, 

	@HasError					BIT OUT,
    @Message					VARCHAR(MAX) OUT,
	@IdRecord					INT OUT
)
AS
BEGIN 

	IF EXISTS (SELECT 1 FROM PosTerminal pt WITH(NOLOCK) WHERE pt.SerialNumber = @SerialNumber AND pt.IdPosTerminal <> @IdPosTerminal)
		SET @Message = CONCAT('There is already a terminal with the Serial Number (', @SerialNumber, ')')
	ELSE IF EXISTS (SELECT 1 FROM PosTerminal pt WITH(NOLOCK) WHERE pt.MAC = @MAC AND pt.IdPosTerminal <> @IdPosTerminal)
		SET @Message = CONCAT('There is already a terminal with the MAC (', @MAC, ')')
	ELSE IF EXISTS (SELECT 1 FROM PosTerminal pt WITH(NOLOCK) WHERE pt.MAC = @MAC AND pt.IdPosTerminal <> @IdPosTerminal)
		SET @Message = CONCAT('There is already a terminal with the Terminal Id (', @TerminalId, ')')

	SET @HasError = IIF(ISNULL(@Message, '') <> '', 1, 0)
	IF @HasError = 1
		RETURN

	BEGIN TRANSACTION
	BEGIN TRY


		IF ISNULL(@IdPosTerminal, 0) > 0
		BEGIN
			UPDATE PosTerminal SET
				SerialNumber = @SerialNumber,
				MAC = @MAC,
				DeviceType = @DeviceType,
				OSVersion = @OSVersion,
				IdAsset = @IdAsset,
				IdGenericStatus = @IdGenericStatus,
				TerminalId = @TerminalId
			WHERE IdPosTerminal = @IdPosTerminal

			SET @IdRecord = @IdPosTerminal
		END
		ELSE
		BEGIN
			INSERT INTO PosTerminal(TerminalId, SerialNumber, MAC, DeviceType, OSVersion, IdAsset, IdGenericStatus, CreationDate, IdUser)
			VALUES (@TerminalId, @SerialNumber, @MAC, @DeviceType, @OSVersion, @IdAsset, @IdGenericStatus, GETDATE(), @IdUser)

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
		VALUES('st_SavePosTerminal', GETDATE(), @MSG_ERROR);
	END CATCH

END
