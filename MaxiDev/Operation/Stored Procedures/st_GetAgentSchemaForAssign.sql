-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-03-24
-- Description:	Save a TopUp scheme // BackOffice-BillPayment
-- =============================================
CREATE PROCEDURE [Operation].[st_GetAgentSchemaForAssign]
(
    @IdAgent INT = NULL,
    @IdProvider INT = NULL
)
AS

	DECLARE @IdOtherProduct INT
	SET @Idprovider = ISNULL(@IdProvider, 2)
	SET @IdOtherProduct =	CASE
								WHEN @IdProvider=2 THEN 7	-- TransferTo Top Up
								WHEN @IdProvider=3 THEN 9	-- Lunex Top Up
								WHEN @IdProvider=5 THEN 17	-- Regalii Top Up
							ELSE 0 END

	IF @IdOtherProduct=7	-- TransferTo Top Up
	BEGIN
		SELECT
			S.[IdSchema]
			, S.[SchemaName]
			, C.[CountryName]
			, CA.[CarrierName]
			, S.[IdProduct]
			, P.[Product]
			, P.[RetailPrice]
			, S.[BeginValue]
			, S.[EndValue]
			, S.[Commission] [AgentCommission]
			, CASE
				WHEN S.[IdCountry] IS NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 0
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 1
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NULL THEN 2
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NOT NULL THEN 3
			END [CommissionType]
			, S.[IdGenericStatus]
			, [Operation].[fn_GetMarginByProvider](@Idprovider, S.[IdCountry], S.[IdCarrier], S.[IdProduct], S.[BeginValue], S.[EndValue]) [Margin]
		FROM [TransFerTo].[Schema] S WITH (NOLOCK)
		LEFT JOIN [TransFerTo].[Country] C WITH (NOLOCK) ON S.[IdCountry]=C.[IdCountry]
		LEFT JOIN [TransFerTo].[Carrier] CA WITH (NOLOCK) ON S.[IdCarrier]=CA.[IdCarrier]
		LEFT JOIN [TransFerTo].[Product] P WITH (NOLOCK) ON S.[IdProduct]=P.[IdProduct]
		WHERE S.[IsDefault]=0
			/*and IdGenericStatus=1*/
			AND S.[IdSchema] IN (
									SELECT A.[IdSchema]
									FROM [TransFerTo].[AgentSchema] A WITH (NOLOCK)
									JOIN [TransFerTo].[schema] S WITH (NOLOCK) ON A.[IdSchema]=S.[IdSchema] AND S.[IdOtherProduct]=@IdOtherProduct
									WHERE A.[IdAgent]=@IdAgent)
			AND S.[IdOtherProduct]=@IdOtherProduct
		ORDER BY S.[IsDefault], S.[IdCountry], S.[IdCarrier], P.[IdProduct]

		SELECT
			S.[IdSchema]
			, S.[SchemaName]
			, C.[CountryName]
			, CA.[CarrierName]
			, S.[IdProduct]
			, P.[Product]
			, P.[RetailPrice]
			, S.[BeginValue]
			, S.[EndValue]
			, S.[Commission] [AgentCommission]
			, CASE
				WHEN S.[IdCountry] IS NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 0
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 1
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NULL THEN 2
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NOT NULL THEN 3
			END [CommissionType]
			, S.[IdGenericStatus]
			, [Operation].[fn_GetMarginByProvider](@Idprovider, S.[IdCountry], S.[IdCarrier], S.[IdProduct], S.[BeginValue], S.[EndValue]) [Margin]
		FROM [TransFerTo].[Schema] S WITH (NOLOCK)
		LEFT JOIN [TransFerTo].[Country] C WITH (NOLOCK) ON S.[IdCountry]=C.[IdCountry]
		LEFT JOIN [TransFerTo].[Carrier] CA WITH (NOLOCK) ON S.[IdCarrier]=CA.[IdCarrier]
		LEFT JOIN [TransFerTo].[Product] P WITH (NOLOCK) ON S.[IdProduct]=P.[IdProduct]
		WHERE S.[IsDefault]=0
			AND S.[IdGenericStatus]=1
			AND S.[IdSchema] NOT IN (
										SELECT A.[IdSchema]
										FROM [TransFerTo].[AgentSchema] A WITH (NOLOCK)
										JOIN [TransFerTo].[schema] S WITH (NOLOCK) ON A.[IdSchema]=S.[IdSchema] AND S.[IdOtherProduct]=@IdOtherProduct
										WHERE A.[IdAgent]=@IdAgent)
			AND S.[IdOtherProduct]=@IdOtherProduct
		ORDER BY S.[IsDefault], S.[IdCountry], S.[IdCarrier], S.[IdProduct]
	END


	IF @IdOtherProduct=9	-- Lunex Top Up
	BEGIN
		SELECT
			S.[IdSchema]
			, S.[SchemaName]
			, C.[CountryName]
			, CA.[CarrierName]
			, S.[IdProduct]
			, NULL [Product]
			, NULL [RetailPrice]
			, S.[BeginValue]
			, S.[EndValue]
			, S.[Commission] [AgentCommission]
			, CASE
				WHEN S.[IdCountry] IS NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 0
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 1
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NULL THEN 2
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NOT NULL THEN 3
			END [CommissionType]
			, S.[IdGenericStatus]
			, [Operation].[fn_GetMarginByProvider](@Idprovider, S.[IdCountry], S.[IdCarrier], S.[IdProduct], S.[BeginValue], S.[EndValue]) [Margin]
		FROM [TransFerTo].[Schema] S WITH (NOLOCK)
		LEFT JOIN [Operation].[Country] C WITH (NOLOCK) ON S.[IdCountry]=C.[IdCountry]
		LEFT JOIN [Operation].[Carrier] CA WITH (NOLOCK) ON S.[IdCarrier]=CA.[IdCarrier]    
		WHERE S.[IsDefault]=0
			/*and IdGenericStatus=1*/
			AND S.[IdSchema] IN (
									SELECT A.[IdSchema]
									FROM [TransFerTo].[AgentSchema] A WITH (NOLOCK)
									JOIN [TransFerTo].[schema] S WITH (NOLOCK) ON A.[IdSchema]=S.[IdSchema] AND S.[IdOtherProduct]=@IdOtherProduct
									WHERE A.[IdAgent]=@IdAgent)
		AND S.[IdOtherProduct]=@IdOtherProduct
		ORDER BY S.[IsDefault], S.[IdCountry], S.[IdCarrier], S.[IdProduct]

		SELECT
			S.[IdSchema]
			, S.[SchemaName]
			, C.[CountryName]
			, CA.[CarrierName]
			, S.[IdProduct]
			, NULL [Product]
			, NULL [RetailPrice]
			, S.[BeginValue]
			, S.[EndValue]
			, S.[Commission] [AgentCommission]
			, CASE
				WHEN S.[IdCountry] IS NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 0
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 1
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NULL THEN 2
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NOT NULL THEN 3
			END [CommissionType]
			, S.[IdGenericStatus]
			, [Operation].[fn_GetMarginByProvider](@Idprovider, S.[IdCountry], S.[IdCarrier], S.[IdProduct], S.[BeginValue], S.[EndValue]) [Margin]
		FROM [TransFerTo].[Schema] S WITH (NOLOCK)
		LEFT JOIN [Operation].[Country] C WITH (NOLOCK) ON S.[IdCountry]=C.[IdCountry]
		LEFT JOIN [Operation].[Carrier] CA WITH (NOLOCK) ON S.[IdCarrier]=CA.[IdCarrier]
		WHERE S.[IsDefault]=0
			AND S.[IdGenericStatus]=1
			AND S.[IdSchema] NOT IN (
										SELECT A.[IdSchema]
										FROM [TransFerTo].[AgentSchema] A WITH (NOLOCK)
										JOIN [TransFerTo].[schema] S WITH (NOLOCK) ON A.[IdSchema]=S.[IdSchema] AND S.[IdOtherProduct]=@IdOtherProduct
										WHERE A.[IdAgent]=@IdAgent)
		AND S.[IdOtherProduct]=@IdOtherProduct
		ORDER BY S.[IsDefault], S.[IdCountry], S.[IdCarrier], S.[IdProduct]
	END

	IF @IdOtherProduct=17	-- Regalii Top Up
	BEGIN

		DECLARE @RegaliiBiller NVARCHAR(MAX)
		EXEC [dbo].[st_GetGlobalAttributeValueByName] 'RegaliiBillerTypeCell', @RegaliiBiller OUTPUT

		SELECT
			S.[IdSchema]
			, S.[SchemaName]
			, C.[CountryName]
			, CA.[Name] [CarrierName]
			, S.[IdProduct]
			, NULL [Product]
			, NULL [RetailPrice]
			, S.[BeginValue]
			, S.[EndValue]
			, S.[Commission] [AgentCommission]
			, CASE
				WHEN S.[IdCountry] IS NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 0
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 1
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NULL THEN 2
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NOT NULL THEN 3
			END [CommissionType]
			, S.[IdGenericStatus]
			, [Operation].[fn_GetMarginByProvider](@Idprovider, S.[IdCountry], S.[IdCarrier], S.[IdProduct], S.[BeginValue], S.[EndValue]) [Margin]
		FROM [TransFerTo].[Schema] S WITH (NOLOCK)
		LEFT JOIN [Operation].[Country] C WITH (NOLOCK) ON S.[IdCountry]=C.[IdCountry]
		LEFT JOIN (
						SELECT [IdBiller], [Name], [IdCountry]
						FROM [Regalii].[Billers] WITH (NOLOCK)
						WHERE [BillerType] = @RegaliiBiller
					) CA ON S.[IdCarrier]=CA.[IdBiller]
		WHERE S.[IsDefault]=0
			/*and IdGenericStatus=1*/
			AND S.[IdSchema] IN (
									SELECT A.[IdSchema]
									FROM [TransFerTo].[AgentSchema] A WITH (NOLOCK)
									JOIN [TransFerTo].[schema] S WITH (NOLOCK) ON A.[IdSchema]=S.[IdSchema] AND S.[IdOtherProduct]=@IdOtherProduct
									WHERE A.[IdAgent]=@IdAgent)
		AND S.[IdOtherProduct]=@IdOtherProduct
		ORDER BY S.[IsDefault], S.[IdCountry], S.[IdCarrier], S.[IdProduct]

		SELECT
			S.[IdSchema]
			, S.[SchemaName]
			, C.[CountryName]
			, CA.[Name] [CarrierName]
			, S.[IdProduct]
			, NULL [Product]
			, NULL [RetailPrice]
			, S.[BeginValue]
			, S.[EndValue]
			, S.[Commission] [AgentCommission]
			, CASE
				WHEN S.[IdCountry] IS NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 0
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 1
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NULL THEN 2
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NOT NULL THEN 3
			END [CommissionType]
			, S.[IdGenericStatus]
			, [Operation].[fn_GetMarginByProvider](@Idprovider, S.[IdCountry], S.[IdCarrier], S.[IdProduct], S.[BeginValue], S.[EndValue]) [Margin]
		FROM [TransFerTo].[Schema] S WITH (NOLOCK)
		LEFT JOIN [Operation].[Country] C WITH (NOLOCK) ON S.[IdCountry]=C.[IdCountry]
		LEFT JOIN (
						SELECT [IdBiller], [Name], [IdCountry]
						FROM [Regalii].[Billers] WITH (NOLOCK)
						WHERE [BillerType] = @RegaliiBiller
					) CA ON S.[IdCarrier]=CA.[IdBiller]
		WHERE S.[IsDefault]=0
			AND S.[IdGenericStatus]=1
			AND S.[IdSchema] NOT IN (
										SELECT A.[IdSchema]
										FROM [TransFerTo].[AgentSchema] A WITH (NOLOCK)
										JOIN [TransFerTo].[schema] S WITH (NOLOCK) ON A.[IdSchema]=S.[IdSchema] AND S.[IdOtherProduct]=@IdOtherProduct
										WHERE A.[IdAgent]=@IdAgent)
		AND S.[IdOtherProduct]=@IdOtherProduct
		ORDER BY S.[IsDefault], S.[IdCountry], S.[IdCarrier], S.[IdProduct]
	END
