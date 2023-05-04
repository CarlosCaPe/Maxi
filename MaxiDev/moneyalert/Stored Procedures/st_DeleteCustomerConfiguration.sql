-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-08-06
-- Description:	Delete Customer's Money Alert configuration by id customer
-- =============================================
CREATE PROCEDURE [MoneyAlert].[st_DeleteCustomerConfiguration]
	-- Add the parameters for the stored procedure here
	@CustomerId INT
AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @CustomerMobileId INT
	SELECT @CustomerMobileId = [IdCustomerMobile] FROM [MoneyAlert].[Customer] WHERE [IdCustomer] = @CustomerId
	IF ISNULL(@CustomerMobileId,0) = 0 RETURN

	DECLARE @CustomerChats TABLE (ChatId INT)

	INSERT INTO @CustomerChats SELECT [IdChat] FROM [MoneyAlert].[Chat] (NOLOCK) WHERE [IdCustomerMobile] = @CustomerMobileId
	
	DELETE FROM [MoneyAlert].[ChatDetail] WHERE [IdChat] IN (SELECT [ChatId] FROM @CustomerChats)
	DELETE FROM [MoneyAlert].[Chat] WHERE [IdChat] IN (SELECT [ChatId] FROM @CustomerChats)
	DELETE FROM [MoneyAlert].[CorporateChat] WHERE [IdChat] IN (SELECT [ChatId] FROM @CustomerChats)
	DELETE FROM [MoneyAlert].[Customer] WHERE [IdCustomer] = @CustomerId
	DELETE FROM [MoneyAlert].[CustomerMobile] WHERE [IdCustomerMobile] = @CustomerMobileId
	
END TRY
BEGIN CATCH
	INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
	VALUES (ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH

