-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-08-03
-- Description:	Check if Money Alert invitation has been send to a Customer
-- =============================================
CREATE PROCEDURE [MoneyAlert].[st_CheckInvitation]
	-- Add the parameters for the stored procedure here
	@CustomerId INT,
	@CellularNumber NVARCHAR(MAX),
	@CustomerMobileId INT OUTPUT,
	@Token NVARCHAR(MAX) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @CellularNumber = REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(@CellularNumber,''),'-',''),' ',''),'(',''),')','')

	DECLARE @CountryCode NVARCHAR(MAX) = [dbo].[GetGlobalAttributeByName]('MoneyAlertCountryCode')

    SELECT @CustomerMobileId = CM.[IdCustomerMobile] , @Token = CM.[Token]
	FROM [MoneyAlert].[CustomerMobile] CM (NOLOCK)
	JOIN [MoneyAlert].[Customer] C (NOLOCK) ON CM.[IdCustomerMobile] = C.[IdCustomerMobile]
	WHERE C.[IdCustomer] = @CustomerId AND CM.[PhoneNumber] = @CellularNumber AND [CountryCode] = @CountryCode

	IF ISNULL(@CustomerMobileId,0) = 0 SET @CustomerMobileId = 0
	IF LTRIM(ISNULL(@Token,'')) = '' SET @Token = ''

END
