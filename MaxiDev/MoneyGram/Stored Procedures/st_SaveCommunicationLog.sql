CREATE PROCEDURE MoneyGram.st_SaveCommunicationLog
(
	@IdPreTransfer		BIGINT,
	@IdTransfer			BIGINT,
	@Action				VARCHAR(200),
	@Request			XML,
	@Response			XML,
	@IdUser				INT
)
AS
BEGIN
	INSERT INTO MoneyGram.CommunicationLogs(IdPreTransfer, IdTransfer, Action, Request, Response, CreationDate, IdUser)
	VALUES
	(@IdPreTransfer, @IdTransfer, @Action, @Request, @Response, GETDATE(), @IdUser)
END

