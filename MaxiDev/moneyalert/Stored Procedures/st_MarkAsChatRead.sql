CREATE PROCEDURE [MoneyAlert].[st_MarkAsChatRead]
(
@IdChat varchar(max),
@IdPersonRole int,
@HasError bit out
)
AS
SET NOCOUNT ON
BEGIN TRY
	SET @HasError=0


	IF @IdPersonRole=1
		UPDATE MoneyAlert.ChatDetail SET ChatMessageStatusId=2 WHERE IdChat=@IdChat AND ChatMessageStatusId=1 AND IdPersonRole=2

	IF @IdPersonRole=2
		UPDATE MoneyAlert.ChatDetail SET ChatMessageStatusId=2 WHERE IdChat=@IdChat AND ChatMessageStatusId=1 AND IdPersonRole=1

      
END TRY
BEGIN CATCH
	SET @HasError=1
	INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
	VALUES (ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH








