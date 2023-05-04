-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-04-11
-- Description:	Insert sms message from Money Alert Api
-- =============================================
CREATE PROCEDURE [moneyalert].[st_InsertTextMessage]
	-- Add the parameters for the stored procedure here
	@CellularNumber NVARCHAR(50), -- should have international code
	@TextMessage NVARCHAR(MAX),
	@HasError BIT OUTPUT,
	@Message NVARCHAR(MAX) OUTPUT

AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @CellularNumber = [dbo].[fn_GetNumeric] (LTRIM(ISNULL(@CellularNumber,'')))
	DECLARE @InterCode NVARCHAR(10) = SUBSTRING(@CellularNumber,1,LEN(@CellularNumber)-10)
	SET @CellularNumber = [dbo].[fnFormatPhoneNumber](SUBSTRING(@CellularNumber, LEN(@CellularNumber)-9, LEN(@CellularNumber)+1))


	EXEC [Infinite].[st_InsertTextMessage]
				@MessageType = 3, -- BeneficiaryInvitation
				@Priority = 3, -- High
				@CellularNumber = @CellularNumber,
				@InterCode = @InterCode,
				@TextMessage = @TextMessage,
				@HasError = @HasError OUTPUT,
				@Message = @Message OUTPUT
	
END TRY
BEGIN CATCH
	SET @HasError=1
	SET @Message = ERROR_MESSAGE()
	INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
	VALUES (ERROR_PROCEDURE(), ERROR_LINE(), @Message, ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH
