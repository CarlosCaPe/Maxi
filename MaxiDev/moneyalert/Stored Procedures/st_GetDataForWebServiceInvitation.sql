-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-08-17
-- Description:	Get data to send invitation by web service
-- =============================================
CREATE PROCEDURE [MoneyAlert].[st_GetDataForWebServiceInvitation]
	-- Add the parameters for the stored procedure here
	@CustomerId INT,
	@SendInvitiation BIT OUTPUT,
	@UriWebService NVARCHAR(MAX) OUTPUT,
	@Message NVARCHAR(MAX) OUTPUT,
	@CellularNumber NVARCHAR(MAX) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	DECLARE @CustomerMobileId INT
	DECLARE @Token NVARCHAR(MAX)
	DECLARE @Cellular NVARCHAR(MAX)
	DECLARE @CountryCode NVARCHAR(MAX)

	SELECT @CustomerMobileId=CM.[IdCustomerMobile], @CountryCode=CM.[CountryCode], @Cellular=CM.[PhoneNumber], @Token = CM.[Token]
	FROM [MoneyAlert].[Customer] C (NOLOCK)
	JOIN [MoneyAlert].[CustomerMobile] CM (NOLOCK) ON C.[IdCustomerMobile] = CM.[IdCustomerMobile]
	WHERE C.[IdCustomer] = @CustomerId

	IF LTRIM(ISNULL(@Token,'')) = ''
	BEGIN
		SET @SendInvitiation = 1
		SET @CellularNumber = @CountryCode + @Cellular
		SELECT @UriWebService = [Value] FROM [dbo].[GlobalAttributes] (NOLOCK) WHERE [Name] = 'MoneyAlertMsgService'
		SELECT @Message = [Value] FROM [dbo].[GlobalAttributes] (NOLOCK) WHERE [Name] = 'MoneyAlertBodyMail'
		
	END
	ELSE
		SET @SendInvitiation = 0

END
