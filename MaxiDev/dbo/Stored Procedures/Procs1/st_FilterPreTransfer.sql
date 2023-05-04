-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-04-08
-- Description:	Returns pretransfer data // This stored is used in FrontOffice - Search pretransfer
-- =============================================
CREATE PROCEDURE [dbo].[st_FilterPreTransfer]
(
    @IdAgent INT,
    @Folio NVARCHAR(max)
)
AS

	IF @Folio='' SET @Folio=null

	SELECT 
		T.[IdAgent]
		, T.[IdPreTransfer]
		, T.[DateOfPreTransfer]
		, A.[AgentCode]
		, A.[AgentName]
		, T.[Folio]
		, T.[CustomerName] + ' ' + T.[CustomerFirstLastName] + ' ' + T.[CustomerSecondLastName] [CustomerName]
		, T.[BeneficiaryName] + ' ' + T.[BeneficiaryFirstLastName] + ' ' + T.[BeneficiarySecondLastName] [BeneficiaryName]
		, P.[PayerName]
		, PT.[PaymentName] [PaymentTypeName]
		, C.[CountryName]
		, T.[AmountInDollars]
		, T.[AmountInMN]
		, T.[IdAgentSchema]
		, T.[IdPaymentType]
		, T.[IdCity]
		, T.[Fee]
		, T.[StateTax]
		, T.[IsValid]
		, CC.[Idcountry]
		, ISNULL(PSSN.[SSNRequired],0) SSNRequired
	FROM dbo.PreTransfer T WITH (NOLOCK)
	JOIN [dbo].[Agent] A WITH (NOLOCK) ON T.[IdAgent]=A.[IdAgent]
	JOIN [dbo].[Payer] P WITH (NOLOCK) ON T.IdPayer=P.IdPayer
	JOIN [dbo].[PaymentType] PT WITH (NOLOCK) ON T.IdPaymentType=PT.IdPaymentType
	JOIN [dbo].[CountryCurrency] CC WITH (NOLOCK) ON T.[IdCountryCurrency] = CC.[IdCountryCurrency]
	JOIN [dbo].[Country] C WITH (NOLOCK) ON CC.[IdCountry] = C.[IdCountry]
	LEFT JOIN [dbo].[PreTransferSSN] PSSN WITH (NOLOCK) ON T.[IdPreTransfer]= PSSN.[IdPreTransfer]
	WHERE T.[IdAgent]=@IdAgent
		AND T.[Folio]=ISNULL(@Folio,T.[Folio])
		AND T.[Status]=0
	ORDER BY T.[DateOfPreTransfer] DESC

