-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-03-24
-- Description:	Returns countries by provider id // This stored is used in Top Up Scheme (BackOffice-Billpayment)
-- =============================================
CREATE procedure [Operation].[st_GetCountry]
(
     @IdProvider INT = NULL,
    @All BIT
)
AS

	DECLARE @IdOtherProduct INT
	SET @IdProvider = ISNULL(@IdProvider,2)
	SET @IdOtherProduct =	CASE
								WHEN @IdProvider=2 THEN 7	-- TransferTo Top Up
								WHEN @IdProvider=3 THEN 9	-- Lunex Top Up
								WHEN @IdProvider=5 THEN 17	-- Regalii Top Up
							ELSE 0 END

	IF @IdOtherProduct=7	-- TransferTo Top Up
	BEGIN
		SELECT
			[IdCountry]
			, [CountryName]
			, [PhoneCountryCode]
			, [IdCountryTTO] [IdCountryProvider]
			, [IdGenericStatus]
		FROM [TransFerTo].[Country] WITH (NOLOCK)
		WHERE [IdGenericStatus] = CASE WHEN @All=1 THEN [IdGenericStatus] ELSE 1 END
		ORDER BY [CountryName]
	END

	IF @IdOtherProduct=9	-- Lunex Top Up
	BEGIN
		SELECT
			[IdCountry]
			, [CountryName]
			, NULL [PhoneCountryCode]
			, [IdCountry] [IdCountryProvider]
			, [IdGenericStatus]
		FROM [Operation].[Country] WITH (NOLOCK)
		WHERE [IdGenericStatus] = CASE WHEN @All=1 THEN [IdGenericStatus] ELSE 1 END
		ORDER BY [CountryName]
	END

	IF @IdOtherProduct=17	-- Regalii Top Up
	BEGIN

		DECLARE @RegaliiBiller NVARCHAR(MAX)
		EXEC [dbo].[st_GetGlobalAttributeValueByName] 'RegaliiBillerTypeCell', @RegaliiBiller OUTPUT

		SELECT
			L.[IdCountry]
			, C.[CountryName]
			, NULL [PhoneCountryCode]
			, L.[IdCountry] [IdCountryProvider]
			, 1 [IdGenericStatus]
		FROM(
				SELECT DISTINCT [IdCountry]
				FROM [Regalii].[Billers] WITH (NOLOCK)
				WHERE [BillerType] = @RegaliiBiller
			) L
		JOIN [dbo].[Country] C WITH (NOLOCK) ON L.[IdCountry] = C.[IdCountry]
		ORDER BY [CountryName]
	END
