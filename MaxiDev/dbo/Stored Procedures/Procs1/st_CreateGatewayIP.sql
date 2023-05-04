CREATE PROCEDURE [dbo].[st_CreateGatewayIP]
(
	@IdGatewayWhiteList	INT,

	@IdGateway			INT,
	@IPAddress			VARCHAR(40),
	@EnterByIdUser		INT,
	@IdStatus			INT,

	@Success			BIT OUT,
	@Message			VARCHAR(200) OUT
)
AS
BEGIN
	DECLARE @MSG_ERROR NVARCHAR(500)
	DECLARE @OutputTable TABLE (
		IdGateway INT, 
		IPAddress VARCHAR(50), 
		CreatedDate DATETIME, 
		EnterByIdUser INT, 
		IdStatus INT
	)

	IF ISNULL(@IdGatewayWhiteList, 0) = 0 AND EXISTS (SELECT 1 FROM GatewayWhiteList gw WHERE gw.IPAddress = @IPAddress AND gw.IdGateway = @IdGateway)
		SET @Message = CONCAT('This gateway already has the IP address (' , @IPAddress, ')')

	IF ISNULL(@Message, '') <> ''
	BEGIN
		SET @Success = 0
		RETURN
	END

	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @RecordExists BIT = 0
		
		IF EXISTS(SELECT 1 FROM GatewayWhiteList gw WHERE gw.IdGatewayWhiteList = @IdGatewayWhiteList)
		BEGIN
			SET @RecordExists = 1

			UPDATE GatewayWhiteList SET
				IdStatus = @IdStatus
			OUTPUT DELETED.IdGateway, DELETED.CreatedDate, DELETED.EnterByIdUser, DELETED.IdStatus 
			INTO @OutputTable(IdGateway, CreatedDate, EnterByIdUser, IdStatus)
			WHERE IdGatewayWhiteList = @IdGatewayWhiteList
		END
		ELSE
		BEGIN
			INSERT INTO GatewayWhiteList(IdGateway, IPAddress, CreatedDate, EnterByIdUser, IdStatus)
			VALUES (@IdGateway, @IPAddress, GETDATE(), @EnterByIdUser, @IdStatus)

			SET @IdGatewayWhiteList = @@identity
		END

		DECLARE @LogMessage VARCHAR(MAX)
		SET @LogMessage = CONCAT(
			CASE WHEN @RecordExists = 1 THEN 'UPDATE' ELSE 'CREATE' END, 
			' IPAddress (', @IPAddress, ')', 
			' by (', @EnterByIdUser, ')',
			' CurrentValues: (',
			(SELECT ga.* FROM GatewayWhiteList ga WHERE ga.IdGatewayWhiteList = @IdGatewayWhiteList FOR XML PATH(''))
			,') OldValues: (', 
			(SELECT * FROM @OutputTable FOR XML PATH(''))
			,')'
		)

		EXEC MAXILOG.dbo.st_CreateOperationBrokerLog 'WhiteList', @LogMessage, NULL, NULL, @EnterByIdUser 
		SET @Success = 1
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		SET @Success = 0
		SET @Message = 'Internal server error'
		IF(ISNULL(@MSG_ERROR, '') = '')
			SET @MSG_ERROR = ERROR_MESSAGE();

		EXEC MAXILOG.dbo.st_CreateOperationBrokerLog 'WhiteList', 'Internal SP Error', @MSG_ERROR, NULL, @EnterByIdUser 

		RAISERROR(@MSG_ERROR, 16, 1);
	END CATCH
END