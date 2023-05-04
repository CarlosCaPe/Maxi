-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-02-18
-- Description:	Get transfer extra info. This stored is used in Corporate (BackOffice)
-- =============================================
CREATE PROCEDURE [dbo].[st_GetTransferExtraInfo]
	-- Add the parameters for the stored procedure here
	@TransferId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	IF EXISTS( SELECT 1 FROM [dbo].[Transfer] WHERE [IdTransfer] = @TransferId )
		SELECT
			T.[IdTransfer]
			, T.[IdBeneficiary]
			, T.[BeneficiaryAddress]
			, T.[BeneficiaryBornDate]
			, T.[BeneficiaryCelularNumber]
			, T.[BeneficiaryCity]
			, T.[BeneficiaryCountry]
			, T.[BeneficiaryName]
			, T.[BeneficiaryFirstLastName]
			, T.[BeneficiarySecondLastName]
			, T.[BeneficiaryNote]
			, T.[BeneficiaryOccupation]
			, T.[BeneficiaryPhoneNumber]
			, T.[BeneficiarySSNumber]
			, T.[BeneficiaryState]
			, T.[BeneficiaryZipcode]
			, T.[IdCustomer]
			, T.[CustomerAddress]
			, T.[CustomerBornDate]
			, T.[CustomerCelullarNumber]
			, T.[CustomerCity]
			, T.[CustomerCountry]
			, T.[CustomerExpirationIdentification]
			, T.[CustomerName]
			, T.[CustomerFirstLastName]
			, T.[CustomerSecondLastName]
			, T.[CustomerIdAgentCreatedBy]
			, T.[CustomerIdCarrier]
			, T.[CustomerIdCustomerIdentificationType]
			, T.[CustomerIdentificationNumber]
			, T.[CustomerName]
			, T.[CustomerOccupation]
			, T.[CustomerPhoneNumber]
			, T.[CustomerSSNumber]
			, T.[CustomerState]
			, T.[CustomerZipcode]
			, C.[PhysicalIdCopy]
		FROM [dbo].[Transfer] T
		JOIN [dbo].[Customer] C ON T.[IdCustomer] = C.[IdCustomer]
		WHERE T.[IdTransfer] = @TransferId
	ELSE
		SELECT
			T.[IdTransferClosed] [IdTransfer]
			, T.[IdBeneficiary]
			, T.[BeneficiaryAddress]
			, T.[BeneficiaryBornDate]
			, T.[BeneficiaryCelularNumber]
			, T.[BeneficiaryCity]
			, T.[BeneficiaryCountry]
			, T.[BeneficiaryName]
			, T.[BeneficiaryFirstLastName]
			, T.[BeneficiarySecondLastName]
			, T.[BeneficiaryNote]
			, T.[BeneficiaryOccupation]
			, T.[BeneficiaryPhoneNumber]
			, T.[BeneficiarySSNumber]
			, T.[BeneficiaryState]
			, T.[BeneficiaryZipcode]
			, T.[IdCustomer]
			, T.[CustomerAddress]
			, T.[CustomerBornDate]
			, T.[CustomerCelullarNumber]
			, T.[CustomerCity]
			, T.[CustomerCountry]
			, T.[CustomerExpirationIdentification]
			, T.[CustomerName]
			, T.[CustomerFirstLastName]
			, T.[CustomerSecondLastName]
			, T.[CustomerIdAgentCreatedBy]
			, T.[CustomerIdCarrier]
			, T.[CustomerIdCustomerIdentificationType]
			, T.[CustomerIdentificationNumber]
			, T.[CustomerName]
			, T.[CustomerOccupation]
			, T.[CustomerPhoneNumber]
			, T.[CustomerSSNumber]
			, T.[CustomerState]
			, T.[CustomerZipcode]
			, C.[PhysicalIdCopy]
		FROM [dbo].[TransferClosed] T
		JOIN [dbo].[Customer] C ON T.[IdCustomer] = C.[IdCustomer]
		WHERE T.[IdTransferClosed] = @TransferId
		

END
