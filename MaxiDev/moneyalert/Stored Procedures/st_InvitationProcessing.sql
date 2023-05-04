-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-08-03
-- Description:	Money Alert Request Invitation
-- =============================================
CREATE PROCEDURE [moneyalert].[st_InvitationProcessing]
	-- Add the parameters for the stored procedure here
	@IdCustomer INT,
	@CountryCode NVARCHAR(MAX),
	@CellularNumber NVARCHAR(MAX),
	@Carrier INT,
	@IsSpanishLanguage BIT,
	@UserId INT,
	@HasError BIT OUTPUT,
	@Message NVARCHAR(MAX) OUTPUT
AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	IF LTRIM(ISNULL(@CellularNumber,'')) = ''
	BEGIN
		SET @HasError = 1
		SELECT @Message = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,105)
		RETURN
	END
	
	DECLARE @CellularNumeric NVARCHAR(100) = [dbo].[fn_GetNumeric] (LTRIM(ISNULL(@CellularNumber,'')))

	SET @HasError = 0
	SET @Message = ''

	DECLARE @SecureCode NVARCHAR(MAX)
	EXEC [MoneyAlert].[st_InviteCustomer] @IdCustomer, @CountryCode, @CellularNumeric, @SecureCode OUTPUT, @HasError OUT
	IF @HasError = 1
	BEGIN
		SELECT @Message = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,104)
		RETURN
	END

	DECLARE @Token NVARCHAR(MAX)
	SELECT @Token = [Token] FROM [MoneyAlert].[CustomerMobile] (NOLOCK) WHERE [PhoneNumber] = @CellularNumeric
	IF ISNULL(@Token,'') = '' -- Send invitation by telephone service provider email
	BEGIN
		DECLARE @TextMessage NVARCHAR(MAX)
		SELECT @TextMessage = [Value] FROM [dbo].[GlobalAttributes] (NOLOCK) WHERE [Name] = 'MoneyAlertBodyMail'
         
		EXEC [Infinite].[st_InsertTextMessage]
					@MessageType = 4, -- CustomerInvitation
					@Priority = 3, -- High
					@CellularNumber = @CellularNumber, 
					@InterCode = @CountryCode,
					@TextMessage = @TextMessage,
					@UserId = @UserId,
					@IsCustomer = 1,
					@HasError = @HasError,
					@Message = @Message

	END

END TRY
BEGIN CATCH
	SET @HasError=1
	SET @Message = ERROR_MESSAGE()
	INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
	VALUES (ERROR_PROCEDURE(), ERROR_LINE(), @Message, ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH
