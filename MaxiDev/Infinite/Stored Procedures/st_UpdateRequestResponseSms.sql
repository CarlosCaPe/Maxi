-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-12-14
-- Description:	Update request-response from provider web service
-- =============================================
CREATE PROCEDURE [Infinite].[st_UpdateRequestResponseSms]
	-- Add the parameters for the stored procedure here
	@TextMessageId BIGINT,
	@Request NVARCHAR(MAX),
	@Response NVARCHAR(MAX),
	@ErrorProcessingMessage BIT,
	@HasError BIT OUTPUT,
	@Message NVARCHAR(MAX) OUTPUT
AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @Status INT = 3 -- Processed
			, @NewLine NVARCHAR(MAX) = CHAR(13) + CHAR(10)
			, @Attemps INT = 1
			, @Date DATETIME = GETDATE()

	IF @ErrorProcessingMessage = 1
		SET @Status = 5 -- Has Error

	UPDATE [Infinite].[TextMessageInfinite] SET
		[Request] = @Request
		, [Response] = @Response
		, [IdTextMessageStatus] = @Status
		, [Attempts] = (ISNULL([Attempts],0) + @Attemps)
		, [LastDateChange] = @Date
	WHERE [IdTextMessageInfinite] = @TextMessageId AND [IdTextMessageStatus] = 2 -- Processing

	SET @HasError = 0
	SET @Message = 'Operation was successful'

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage=ERROR_MESSAGE()
	SET @HasError = 1
	SET @Message = 'Error trying update'
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_UpdateRequestResponseSms', GETDATE(), @ErrorMessage)
END CATCH
