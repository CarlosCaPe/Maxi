-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-03-22
-- Description:	Return schema by id and provider id // This stored is used in MaxiBackOffice-Billpayments (TopUp Scheme)
-- =============================================
CREATE PROCEDURE [Operation].[st_GetSchemaByID]
(
    @IdSchema INT,
    @Idprovider INT = NULL,
	@MargenForNewSchemeOnly MONEY OUTPUT
)
AS
	DECLARE @IdOtherProduct INT
	SET @Idprovider = ISNULL(@Idprovider,2)
	SET @IdOtherProduct =	CASE
								WHEN @IdProvider=2 THEN 7	-- TransferTo Top Up
								WHEN @IdProvider=3 THEN 9	-- Lunex Top Up
								WHEN @IdProvider=5 THEN 17	-- Regalii Top Up
							ELSE 0 END
	
	IF @IdSchema <= 0
		SET @MargenForNewSchemeOnly = [Operation].[fn_GetMarginByProvider](@Idprovider, NULL, NULL, NULL, NULL, NULL)
	ELSE
		SET @MargenForNewSchemeOnly = 0

	IF @IdOtherProduct=7	-- TransferTo Top Up
	BEGIN
		SELECT 
			S.[IdSchema]
			, S.[SchemaName]
			, S.[IdCountry]
			, C.[CountryName]
			, S.[IdCarrier]
			, CA.[CarrierName]
			, S.[IdProduct]
			, P.[Product]
			, S.[BeginValue]
			, S.[EndValue]
			, S.[Commission]
			, [Operation].[fn_GetMarginByProvider](@Idprovider, S.[IdCountry], S.[IdCarrier], S.[IdProduct], S.[BeginValue], S.[EndValue]) [Margen]
			, S.[IsDefault]
			, CASE
				WHEN S.[IdCountry] IS NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 0
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 1
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NULL THEN 2
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NOT NULL THEN 3
			END [CommissionType]
		FROM [TransFerTo].[Schema] S WITH (NOLOCK)
		LEFT JOIN [TransFerTo].[Country] C WITH (NOLOCK) ON S.[IdCountry]=C.[IdCountry]
		LEFT JOIN [TransFerTo].[Carrier] CA WITH (NOLOCK) ON S.[IdCarrier]=CA.[IdCarrier]
		LEFT JOIN [TransFerTo].[Product] P WITH (NOLOCK) ON S.[IdProduct]=P.[IdProduct]
		WHERE S.[IdSchema]=@IdSchema
			AND S.[IdOtherProduct]=@IdOtherProduct
		ORDER BY S.[IsDefault], S.[IdCountry], S.[IdCarrier], S.[IdProduct]
	END

	IF @IdOtherProduct=9	-- Lunex Top Up
	BEGIN
		SELECT 
			S.[IdSchema]
			, S.[SchemaName]
			, S.[IdCountry]
			, C.[CountryName]
			, S.[IdCarrier]
			, CA.[CarrierName]
			, S.[IdProduct]
			, NULL [Product]
			, S.[BeginValue]
			, S.[EndValue]
			, S.[Commission]
			, [Operation].[fn_GetMarginByProvider](@Idprovider, S.[IdCountry], S.[IdCarrier], S.[IdProduct], S.[BeginValue], S.[EndValue]) [Margen]
			, S.[IsDefault]
			, CASE
				WHEN S.[IdCountry] IS NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 0
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 1
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NULL THEN 2
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NOT NULL THEN 3
			END [CommissionType]
		FROM [TransFerTo].[Schema] S WITH (NOLOCK)
		LEFT JOIN [Operation].[Country] C WITH (NOLOCK) ON S.[IdCountry]=C.[IdCountry]
		LEFT JOIN [Operation].[Carrier] CA WITH (NOLOCK) ON S.[IdCarrier]=CA.[IdCarrier]
		WHERE S.[IdSchema]=@IdSchema
			AND S.[IdOtherProduct]=@IdOtherProduct
		ORDER BY S.[IsDefault], S.[IdCountry], S.[IdCarrier], S.[IdProduct]
	END

	IF @IdOtherProduct = 17	-- Regalii Top Up
	BEGIN
		
		DECLARE @RegaliiBiller NVARCHAR(MAX)
		EXEC [dbo].[st_GetGlobalAttributeValueByName] 'RegaliiBillerTypeCell', @RegaliiBiller OUTPUT

		SELECT 
			S.[IdSchema]
			, S.[SchemaName]
			, S.[IdCountry]
			, C.[CountryName]
			, S.[IdCarrier]
			, CA.[Name] [CarrierName]
			, S.[IdProduct]
			, NULL [Product]
			, S.[BeginValue]
			, S.[EndValue]
			, S.[Commission]
			, [Operation].[fn_GetMarginByProvider](@Idprovider, S.[IdCountry], S.[IdCarrier], S.[IdProduct], S.[BeginValue], S.[EndValue]) [Margen]
			, S.[IsDefault]
			, CASE
				WHEN S.[IdCountry] IS NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 0
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 1
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NULL THEN 2
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NOT NULL THEN 3
			END [CommissionType]
		FROM [TransFerTo].[Schema] S WITH (NOLOCK)
		LEFT JOIN [dbo].[Country] C WITH (NOLOCK) ON S.[IdCountry]=C.[IdCountry]
		LEFT JOIN (
						SELECT [IdBiller], [Name], [IdCountry]
						FROM [Regalii].[Billers] WITH (NOLOCK)
						WHERE [BillerType] = @RegaliiBiller
					) CA ON S.[IdCarrier]=CA.[IdBiller]
		WHERE S.[IdSchema]=@IdSchema
			AND S.[IdOtherProduct]=@IdOtherProduct
		ORDER BY S.[IsDefault], S.[IdCountry], S.[IdCarrier], S.[IdProduct]

	END