-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-01-21
-- Description:	Get required filds by transfer for Compliance Format 002
-- =============================================
CREATE PROCEDURE [dbo].[st_GetFieldsForComplianceFormat002]
	-- Add the parameters for the stored procedure here
	@TransferId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF EXISTS (SELECT TOP 1 1 FROM [dbo].[Transfer] WITH (NOLOCK) WHERE [IdTransfer] = @TransferId)
		SELECT
			T.[DateOfTransfer]
			, T.[ClaimCode]
			, A.[AgentCode]
			, A.[AgentName]
			, T.[AmountInDollars]
			, CU.[CurrencyName]
			, T.[CustomerName]
			, LTRIM(ISNULL(T.[CustomerFirstLastName],'') + ' ' + ISNULL(T.[CustomerSecondLastName],'')) [CustomerLastName]
			, T.[BeneficiaryName]
			, LTRIM(ISNULL(T.[BeneficiaryFirstLastName],'') + ' ' + ISNULL(T.[BeneficiarySecondLastName],'')) [BeneficiaryLastName]
			,ISNULL(CIT.[Name],'') [CustomerIdentificationType]
			,ISNULL(T.[CustomerIdentificationNumber],'') [CustomerIdentificationNumber]
			,CASE
				WHEN T.[CustomerIdentificationIdCountry] IS NOT NULL THEN CO.[CountryName]
				WHEN T.[CustomerIdentificationIdState] IS NOT NULL THEN S2.[StateName] + ', USA'
				ELSE ''
			END [CustomerIdentificationExpeditionPlace]
			,T.[CustomerBornDate] [CustomerBornDate]
			,ISNULL(L.[Country],'') [CustomerCountryOfBirth]
			,ISNULL(T.[CustomerOccupation],'') [CustomerOccupation]
			,T.[CustomerAddress]
			,T.[CustomerCountry]
			,T.[CustomerCity]
			,T.[CustomerState]
			,T.[CustomerPhoneNumber]
			,ISNULL(BENIT.[Name],'') [BeneficiaryIdentificationType]
			,CASE
				WHEN T.[IdBeneficiaryIdentificationType] IS NULL THEN ''
				ELSE 'BRASIL'
			END [BeneficiaryIdentificationExpeditionPlace]
			,ISNULL(T.[BeneficiaryIdentificationNumber],'') [BeneficiaryIdentificationNumber]
			,T.[BeneficiaryAddress]
			,T.[BeneficiaryCity]
			,T.[BeneficiaryState]
			,T.[BeneficiaryCountry]
			--,T.[CustomerExpirationIdentification] [ExpirationDate]
			--,ISNULL(T.[CustomerSSNumber],'') [SsnOrTaxId]
			,ISNULL(T.[MoneySource],'') [MoneySource]
			,ISNULL(T.[Purpose],'') [PurposeOfTransfer]
			,ISNULL(T.[Relationship],'') [RelationshipWithRecipient]
			--,LTRIM(ISNULL(OWB.[Name],'') + ' ' + ISNULL(OWB.[FirstLastName],'') + ' ' + ISNULL(OWB.[SecondLastName],'')) Owb
			--,ISNULL(C.[CityName] + ', ' + S.[StateName], ISNULL(C.[CityName],'') + ISNULL(S.[StateName],'')) DestinationCityAndState
		FROM [dbo].[Transfer] T WITH (NOLOCK)
		JOIN [dbo].[Agent] A WITH (NOLOCK) ON T.[IdAgent] = A.[IdAgent]
		JOIN [dbo].[CountryCurrency] CC WITH (NOLOCK) ON T.[IdCountryCurrency] = CC.[IdCountryCurrency]
		JOIN [dbo].[Currency] CU WITH (NOLOCK) ON CC.[IdCurrency] = CU.[IdCurrency]
		LEFT JOIN [dbo].[Branch] B WITH (NOLOCK) ON T.[IdBranch] = B.[IdBranch]
		--JOIN [dbo].[City] C WITH (NOLOCK) ON B.[IdCity] = C.[IdCity]
		--JOIN [dbo].[State] S WITH (NOLOCK) ON C.[IdState] = S.[IdState]
		LEFT JOIN [dbo].[CustomerIdentificationType] CIT WITH (NOLOCK) ON T.[CustomerIdCustomerIdentificationType] = CIT.[IdCustomerIdentificationType]
		LEFT JOIN [dbo].[BeneficiaryIdentificationType] BENIT WITH (NOLOCK) ON T.[IdBeneficiaryIdentificationType] = BENIT.[IdBeneficiaryIdentificationType]
		--LEFT JOIN [dbo].[OnWhoseBehalf] OWB WITH (NOLOCK) ON T.[IdOnWhoseBehalf] = OWB.[IdOnWhoseBehalf]
		LEFT JOIN [dbo].[Country] CO WITH (NOLOCK) ON T.[CustomerIdentificationIdCountry] = CO.[IdCountry]
		LEFT JOIN [dbo].[State] S2 WITH (NOLOCK) ON T.[CustomerIdentificationIdState] = S2.[IdState]
		LEFT JOIN (
			SELECT CH2.[IdCustomer], CB.[Country]
		FROM [dbo].[Checks] CH2 WITH (NOLOCK)
		LEFT JOIN [dbo].[CountryBirth] CB ON (CB.IdCountryBirth = CH2.[CountryBirthId])
		WHERE CH2.[IdCheck] IN (
			SELECT MAX(CH.[IdCheck]) [IdCheck]
			FROM [dbo].[Checks] CH WITH (NOLOCK)
			WHERE CH.[CountryBirthId] IS NOT NULL
			GROUP BY CH.[IdCustomer] )
		) L  ON T.[IdCustomer] = L.[IdCustomer]
		WHERE T.[IdTransfer] = @TransferId

	ELSE
			SELECT
			T.[DateOfTransfer]
			, T.[ClaimCode]
			, A.[AgentCode]
			, A.[AgentName]
			, T.[AmountInDollars]
			, CU.[CurrencyName]
			, T.[CustomerName]
			, LTRIM(ISNULL(T.[CustomerFirstLastName],'') + ' ' + ISNULL(T.[CustomerSecondLastName],'')) [CustomerLastName]
			, T.[BeneficiaryName]
			, LTRIM(ISNULL(T.[BeneficiaryFirstLastName],'') + ' ' + ISNULL(T.[BeneficiarySecondLastName],'')) [BeneficiaryLastName]
			,ISNULL(CIT.[Name],'') [CustomerIdentificationType]
			,ISNULL(T.[CustomerIdentificationNumber],'') [CustomerIdentificationNumber]
			,CASE
				WHEN T.[CustomerIdentificationIdCountry] IS NOT NULL THEN CO.[CountryName]
				WHEN T.[CustomerIdentificationIdState] IS NOT NULL THEN S2.[StateName] + ', USA'
				ELSE ''
			END [CustomerIdentificationExpeditionPlace]
			,T.[CustomerBornDate] [CustomerBornDate]
			,ISNULL(L.[Country],'') [CustomerCountryOfBirth]
			,ISNULL(T.[CustomerOccupation],'') [CustomerOccupation]
			,T.[CustomerAddress]
			,T.[CustomerCountry]
			,T.[CustomerCity]
			,T.[CustomerState]
			,T.[CustomerPhoneNumber]
			,ISNULL(BENIT.[Name],'') [BeneficiaryIdentificationType]
			,CASE
				WHEN T.[IdBeneficiaryIdentificationType] IS NULL THEN ''
				ELSE 'BRASIL'
			END [BeneficiaryIdentificationExpeditionPlace]
			,ISNULL(T.[BeneficiaryIdentificationNumber],'') [BeneficiaryIdentificationNumber]
			,T.[BeneficiaryAddress]
			,T.[BeneficiaryCity]
			,T.[BeneficiaryState]
			,T.[BeneficiaryCountry]
			--,T.[CustomerExpirationIdentification] [ExpirationDate]
			--,ISNULL(T.[CustomerSSNumber],'') [SsnOrTaxId]
			,ISNULL(T.[MoneySource],'') [MoneySource]
			,ISNULL(T.[Purpose],'') [PurposeOfTransfer]
			,ISNULL(T.[Relationship],'') [RelationshipWithRecipient]
			--,LTRIM(ISNULL(OWB.[Name],'') + ' ' + ISNULL(OWB.[FirstLastName],'') + ' ' + ISNULL(OWB.[SecondLastName],'')) Owb
			--,ISNULL(C.[CityName] + ', ' + S.[StateName], ISNULL(C.[CityName],'') + ISNULL(S.[StateName],'')) DestinationCityAndState
		FROM [dbo].[TransferClosed] T WITH (NOLOCK)
		JOIN [dbo].[Agent] A WITH (NOLOCK) ON T.[IdAgent] = A.[IdAgent]
		JOIN [dbo].[CountryCurrency] CC WITH (NOLOCK) ON T.[IdCountryCurrency] = CC.[IdCountryCurrency]
		JOIN [dbo].[Currency] CU WITH (NOLOCK) ON CC.[IdCurrency] = CU.[IdCurrency]
		LEFT JOIN [dbo].[Branch] B WITH (NOLOCK) ON T.[IdBranch] = B.[IdBranch]
		--JOIN [dbo].[City] C WITH (NOLOCK) ON B.[IdCity] = C.[IdCity]
		--JOIN [dbo].[State] S WITH (NOLOCK) ON C.[IdState] = S.[IdState]
		LEFT JOIN [dbo].[CustomerIdentificationType] CIT WITH (NOLOCK) ON T.[CustomerIdCustomerIdentificationType] = CIT.[IdCustomerIdentificationType]
		LEFT JOIN [dbo].[BeneficiaryIdentificationType] BENIT WITH (NOLOCK) ON T.[IdBeneficiaryIdentificationType] = BENIT.[IdBeneficiaryIdentificationType]
		--LEFT JOIN [dbo].[OnWhoseBehalf] OWB WITH (NOLOCK) ON T.[IdOnWhoseBehalf] = OWB.[IdOnWhoseBehalf]
		LEFT JOIN [dbo].[Country] CO WITH (NOLOCK) ON T.[CustomerIdentificationIdCountry] = CO.[IdCountry]
		LEFT JOIN [dbo].[State] S2 WITH (NOLOCK) ON T.[CustomerIdentificationIdState] = S2.[IdState]
		LEFT JOIN (
			SELECT CH2.[IdCustomer], CB.[Country]
		FROM [dbo].[Checks] CH2 WITH (NOLOCK)
		LEFT JOIN [dbo].[CountryBirth] CB ON (CB.IdCountryBirth = CH2.[CountryBirthId])
		WHERE CH2.[IdCheck] IN (
			SELECT MAX(CH.[IdCheck]) [IdCheck]
			FROM [dbo].[Checks] CH WITH (NOLOCK)
			WHERE CH.[CountryBirthId] IS NOT NULL
			GROUP BY CH.[IdCustomer] )
		) L  ON T.[IdCustomer] = L.[IdCustomer]
		WHERE T.[IdTransferClosed] = @TransferId

END

