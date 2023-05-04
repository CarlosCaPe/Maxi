CREATE PROCEDURE [Infinite].[st_UpdateTextMessageFromProvider]
	-- Add the parameters for the stored procedure here
	@TextMessageInfiniteId BIGINT,
	@ProviderStatus INT,
	@MessageProvider NVARCHAR(MAX) = NULL,
	@Source NVARCHAR(MAX) = NULL,
	@HasError BIT OUTPUT,
	@Message NVARCHAR(MAX) OUTPUT
AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	IF @TextMessageInfiniteId <= 0
	BEGIN
	
		INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_UpdateTextMessageFromProvider', GETDATE(), '1 Cellular Update')

		SET @Source = [dbo].[fn_GetNumeric] (LTRIM(ISNULL(@Source,'')))
		
		INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_UpdateTextMessageFromProvider', GETDATE(), '2 Source ' + @Source)

		DECLARE @SourceWithFormat NVARCHAR(MAX) = SUBSTRING(@Source, LEN(@Source)-9, LEN(@Source)+1)
		SET @SourceWithFormat = [dbo].[fnFormatPhoneNumber](@SourceWithFormat)
		
		DECLARE @SourceWithoutInterCodce NVARCHAR(MAX) = [dbo].[fn_GetNumeric] (LTRIM(ISNULL(@SourceWithFormat,'')))
		
		INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_UpdateTextMessageFromProvider', GETDATE(), '3 Source with format ' + @SourceWithFormat)

		DECLARE @InterCode NVARCHAR(10) = SUBSTRING(@Source,1,LEN(@Source)-10)
		
		INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_UpdateTextMessageFromProvider', GETDATE(), '4 InterCode ' + @InterCode)

		DECLARE @SubscribeWords NVARCHAR(MAX) = [dbo].[GetGlobalAttributeByName]('InfiniteSubscriptionWords')
		DECLARE @UnsubscribeWords NVARCHAR(MAX) = [dbo].[GetGlobalAttributeByName]('InfiniteUnsubscriptionWords')
		DECLARE @RowsAffected INT = 0
		DECLARE @IdCustomer INT = 0
		
		SELECT * INTO #tmpSubscribeWords FROM FnSplitTable(@SubscribeWords, ',')
		
		SELECT * INTO #tmpUnSubscribeWords FROM FnSplitTable(@UnsubscribeWords, ',')	
		
		
		
		IF EXISTS (SELECT 1 FROM #tmpSubscribeWords WHERE CHARINDEX(REPLACE(part,' ',''),REPLACE(@MessageProvider,' ','')) > 0)  --CHARINDEX(REPLACE(@SubscribeWords,' ',''),REPLACE(@MessageProvider,' ','')) > 0 -- Allow receive message
		BEGIN
			INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_UpdateTextMessageFromProvider', GETDATE(), '5 Entra MAXI SI')
			UPDATE [Infinite].[CellularNumber] SET [AllowSentMessages] = 1, [LastChangeDate] = GETDATE() WHERE [AllowSentMessages] = 0 AND [InterCode] = @InterCode AND [NumberWithFormat] IN (@SourceWithFormat, @SourceWithoutInterCodce)
			
			SET @RowsAffected = @@ROWCOUNT			
			
			SELECT TOP 1 @IdCustomer = IdCustomer FROM Infinite.CellularNumber WHERE NumberWithFormat IN (@SourceWithFormat, @SourceWithoutInterCodce)
			
			UPDATE dbo.Customer SET ReceiveSms = 1 WHERE IdCustomer = @IdCustomer
		END
		
		IF EXISTS (SELECT 1 FROM #tmpUnSubscribeWords WHERE CHARINDEX(REPLACE(part,' ',''),REPLACE(@MessageProvider,' ','')) > 0)--CHARINDEX(REPLACE(@UnsubscribeWords,' ',''),REPLACE(@MessageProvider,' ','')) > 0 -- Unsubscribe to receive message
		BEGIN
			INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_UpdateTextMessageFromProvider', GETDATE(), '5 Entra MAXI NO')
			UPDATE [Infinite].[CellularNumber] SET [AllowSentMessages] = 0, [LastChangeDate] = GETDATE() WHERE [AllowSentMessages] = 1 AND [InterCode] = @InterCode AND [NumberWithFormat] IN (@SourceWithFormat, @SourceWithoutInterCodce)
			
			SET @RowsAffected = @@ROWCOUNT
			INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_UpdateTextMessageFromProvider', GETDATE(), '6 Source: ' + @SourceWithoutInterCodce + ', Source with format: ' + @SourceWithFormat)
			SELECT TOP 1 @IdCustomer = IdCustomer FROM Infinite.CellularNumber WHERE NumberWithFormat IN (@SourceWithFormat, @SourceWithoutInterCodce)
			
			UPDATE dbo.Customer SET ReceiveSms = 0 WHERE IdCustomer = @IdCustomer
		END

		IF @RowsAffected = 0
		BEGIN
			SET @HasError = 1
			SET @Message = 'No row was updated'
			RETURN
		END

	END
	ELSE
	BEGIN
		UPDATE [Infinite].[TextMessageInfinite] SET
						[IdTextMessageStatus] = CASE
												WHEN @ProviderStatus IN (1,2) THEN 4
												WHEN @ProviderStatus IN (3,4,5,6,8) THEN 5
												WHEN @ProviderStatus = 7 THEN 6
												ELSE [IdTextMessageStatus] END
						, [ProviderStatus] = CASE @ProviderStatus  WHEN 0 THEN [ProviderStatus] ELSE @ProviderStatus END
						, [ErrorMessageProvider] = @MessageProvider
						, [LastDateChange] = GETDATE()
		WHERE [IdTextMessageInfinite] = @TextMessageInfiniteId

		IF @@ROWCOUNT = 0
		BEGIN
			SET @HasError = 1
			SET @Message = 'No row was updated'
			RETURN
		END
	END

	SET @HasError = 0
	SET @Message = 'Operation was successful'

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage=ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_UpdateTextMessageFromProvider', GETDATE(), @ErrorMessage)
	SET @HasError = 1
	SET @Message = 'Error trying update'
END CATCH

