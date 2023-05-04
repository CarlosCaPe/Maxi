
-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-05-18
-- Description:	Exec CLR procedure for send mobile notification by ClaimCode
-- =============================================
CREATE PROCEDURE [dbo].[st_SendMobileNotificationByClaimCode]
	-- Add the parameters for the stored procedure here
	@ClaimCode NVARCHAR(MAX),
	@HasError BIT OUTPUT,
	@Message NVARCHAR(MAX) OUTPUT
AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @webUrl NVARCHAR(MAX),
			@beneficiaryToken NVARCHAR(MAX),
			@customerToken NVARCHAR(MAX),
			@beneficiaryFullName NVARCHAR(MAX),
			@customerFullName NVARCHAR(MAX),
			@statusId INT,
			@transferId BIGINT,
			@beneficiaryTypeId INT,
			@customerTypeId INT,
			@taskId INT

	SELECT @webUrl = [dbo].[GetGlobalAttributeByName] ('MoneyAlertNotificationsUri')
	SET @taskId = 5

	SELECT
	@transferId = T.[IdTransfer]
	,@statusId = T.[IdStatus]
	,@beneficiaryFullName = B.[Name]
	,@beneficiaryToken = isnull(B.[Token],'')
	,@beneficiaryTypeId = isnull(B.[IdPhoneType],0)
	,@customerFullName = C.[Name]
	,@customerToken = isnull(C.[Token],'')
	,@customerTypeId = isnull(C.[IdPhoneType],0)
	FROM [dbo].[Transfer] T (NOLOCK)
	join [MoneyAlert].Customer cu WITH(NOLOCK) on T.IdCustomer = Cu.IdCustomer
    join [MoneyAlert].Beneficiary be WITH(NOLOCK) on T.IdBeneficiary = Be.IdBeneficiary
	JOIN [MoneyAlert].[BeneficiaryMobile] B (NOLOCK) ON be.IdBeneficiaryMobile = B.IdBeneficiaryMobile
	JOIN [MoneyAlert].[CustomerMobile] C (NOLOCK) ON cu.IdCustomerMobile = C.IdCustomerMobile
	WHERE T.[ClaimCode] = @ClaimCode

	SET @statusId = CASE 
					WHEN @statusId = 22 THEN 2 -- CANCELLED
					WHEN @statusId = 23 THEN 3 -- PAYMENT READY
					WHEN @statusId = 30 THEN 4 -- PAID
					WHEN @statusId = 31 THEN 5 -- REJECTED
					WHEN @statusId IN (24,25,26,27,28,29) THEN 6 -- CONTACT MAXI
					ELSE 1 -- IN PROGRESS
					END

    --select @webUrl '@webUrl',@beneficiaryToken '@beneficiaryToken',@customerToken '@customerToken',@beneficiaryFullName '@beneficiaryFullName',@customerFullName '@customerFullName',@statusId '@statusId',@transferId '@transferId',@beneficiaryTypeId '@beneficiaryTypeId',@customerTypeId '@customerTypeId',@taskId '@taskId'

	IF @transferId IS NOT NULL
		EXEC [dbo].[st_SendMobileNotification]
			@webUrl = @webUrl,
			@beneficiaryToken = @beneficiaryToken,
			@customerToken = @customerToken,
			@beneficiaryFullName = @beneficiaryFullName,
			@customerFullName = @customerFullName,
			@statusId = @statusId,
			@transferId = @transferId,
			@beneficiaryTypeId = @beneficiaryTypeId,
			@customerTypeId = @customerTypeId,
			@taskId = @taskId,
			@HasError = @HasError OUTPUT,
			@Message = @Message OUTPUT
	ELSE
	BEGIN
		SET @HasError = 1
		SET @Message = 'Transfer was not found'
	END

END TRY
BEGIN CATCH
	SET @HasError = 1
	SET @Message = ERROR_MESSAGE()
	INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
	VALUES (ERROR_PROCEDURE(), ERROR_LINE(), @Message, ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH
