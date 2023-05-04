CREATE PROCEDURE [Corp].[st_GetSchema_Operation]
(
    @IsDefault BIT,
    @ShowDisable BIT, 
    @CommissionType INT,
    @IdProvider INT = NULL
)
AS
-- =============================================
-- Author:		Dario Almeida
-- Create date: 2017-05-30
-- Description: Returns Fee for Lunex products

	DECLARE @IdOtherProduct INT
	SET @IdProvider = ISNULL(@IdProvider,2)
	SET @IdOtherProduct =	CASE
								WHEN @IdProvider=2 THEN 7	-- TransferTo Top Up
								WHEN @IdProvider=3 THEN 9	-- Lunex Top Up
								WHEN @IdProvider=5 THEN 17	-- Regalii Top Up
							ELSE 0 END

	IF @IdOtherProduct=7	-- TransferTo Top Up
	BEGIN
		IF @CommissionType = 0	-- All
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
				, P.[RetailPrice]
				, S.[BeginValue]
				, S.[EndValue]
				, S.[Commission]
				, [Operation].[fn_GetMarginByProvider](@Idprovider, S.[IdCountry], S.[IdCarrier], S.[IdProduct], S.[BeginValue], S.[EndValue]) [Margen]
				, S.[IsDefault]
				, S.[IdGenericStatus],
			CASE 
				WHEN S.[IdCountry] IS NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 0
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 1
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NULL THEN 2
				WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NOT NULL THEN 3
			END [CommissionType]
				, 0 AS [Fee]
			FROM [TransFerTo].[Schema] S WITH (NOLOCK)
			LEFT JOIN [TransFerTo].[Country] C WITH (NOLOCK) ON S.[IdCountry]=C.[IdCountry]
			LEFT JOIN [TransFerTo].[Carrier] CA WITH (NOLOCK) ON S.[IdCarrier]=CA.[IdCarrier]
			LEFT JOIN [TransFerTo].[Product] P WITH (NOLOCK) ON S.[IdProduct]=P.[IdProduct]
			WHERE
				S.[IdOtherProduct]=@IdOtherProduct
				AND S.[IsDefault]=@IsDefault
				AND S.[IdGenericStatus] = CASE WHEN @ShowDisable=1 THEN S.[IdGenericStatus] ELSE 1 END
				AND (S.[IdCountry] IS NOT NULL OR S.[IdCarrier] IS NOT NULL OR S.[IdProduct] IS NOT NULL)
			ORDER BY [SchemaName]--IsDefault,IdCountry,IdCarrier,IdProduct
			--return
		END

		IF @CommissionType = 1	-- Country
		BEGIN
			SELECT
				S.[IdSchema]
				, S.[SchemaName]
				, S.[IdCountry]
				, C.[Countryname]
				, S.[IdCarrier]
				, CA.[CarrierName]
				, S.[IdProduct]
				, P.[Product]
				, P.[RetailPrice]
				, S.[BeginValue]
				, S.[EndValue]
				, S.[Commission]
				, [Operation].[fn_GetMarginByProvider](@Idprovider, S.[IdCountry], S.[IdCarrier], S.[IdProduct], S.[BeginValue], S.[EndValue]) Margen
				, S.[IsDefault]
				, S.[IdGenericStatus]
				, CASE 
					WHEN S.[IdCountry] IS NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 0
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 1
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NULL THEN 2
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NOT NULL THEN 3
				END [CommissionType]
				, 0 AS [Fee]
			FROM [TransFerTo].[Schema] S WITH (NOLOCK)
			LEFT JOIN [TransFerTo].[Country] C WITH (NOLOCK) ON S.[IdCountry]=C.[IdCountry]
			LEFT JOIN [TransFerTo].[Carrier] CA WITH (NOLOCK) ON S.[IdCarrier]=CA.[IdCarrier]
			LEFT JOIN [TransFerTo].[Product] P WITH (NOLOCK) ON S.[IdProduct]=P.[IdProduct]
			WHERE
				S.[IdOtherProduct]=@IdOtherProduct
				AND S.[IsDefault]=@IsDefault
				AND S.[IdGenericStatus] = CASE WHEN @ShowDisable=1 THEN S.[IdGenericStatus] ELSE 1 END
				AND S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL
			ORDER BY S.[SchemaName]--IsDefault,IdCountry,IdCarrier,IdProduct
			--return
		END

		IF @CommissionType = 2	-- Carrier
		BEGIN
			SELECT
				S.[IdSchema]
				, S.[SchemaName]
				, S.[IdCountry]
				, C.[Countryname]
				, S.[IdCarrier]
				, CA.[CarrierName]
				, S.[IdProduct]
				, P.[Product]
				, P.[RetailPrice]
				, S.[BeginValue]
				, S.[EndValue]
				, S.[Commission]
				, [Operation].[fn_GetMarginByProvider](@Idprovider, S.[IdCountry], S.[IdCarrier], S.[IdProduct], S.[BeginValue], S.[EndValue]) [Margen]
				, S.[IsDefault]
				, S.[IdGenericStatus]
				, CASE
					WHEN S.[IdCountry] IS NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 0
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 1
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NULL THEN 2
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NOT NULL THEN 3
				END [CommissionType]
				, 0 AS [Fee]
			FROM [TransFerTo].[Schema] S WITH (NOLOCK)
			LEFT JOIN [TransFerTo].[Country] C WITH (NOLOCK) ON S.[IdCountry]=C.[IdCountry]
			LEFT JOIN [TransFerTo].[Carrier] CA WITH (NOLOCK) ON S.[IdCarrier]=CA.[IdCarrier]
			LEFT JOIN [TransFerTo].[Product] P WITH (NOLOCK) ON S.[IdProduct]=P.[IdProduct]
			WHERE
				S.[IdOtherProduct]=@IdOtherProduct
				AND S.[IsDefault]=@IsDefault
				AND	S.[IdGenericStatus] = CASE WHEN @ShowDisable=1 THEN S.[IdGenericStatus] ELSE 1 END
				AND S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NULL
			ORDER BY S.[SchemaName]--IsDefault,IdCountry,IdCarrier,IdProduct
			--return
		END

		IF @CommissionType = 3 -- Product
		BEGIN
			SELECT
				S.[IdSchema]
				, S.[SchemaName]
				, S.[IdCountry]
				, C.[Countryname]
				, S.[IdCarrier]
				, CA.[CarrierName]
				, S.[IdProduct]
				, P.[Product]
				, P.[RetailPrice]
				, S.[BeginValue]
				, S.[EndValue]
				, S.[Commission]
				, [Operation].[fn_GetMarginByProvider](@Idprovider, S.[IdCountry], S.[IdCarrier], S.[IdProduct], S.[BeginValue], S.[EndValue]) [Margen]
				, S.[IsDefault]
				, S.[IdGenericStatus]
				, CASE
					WHEN S.[IdCountry] IS NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 0
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 1
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NULL THEN 2
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NOT NULL THEN 3
				END [CommissionType]
				, 0 AS [Fee]
			FROM [TransFerTo].[Schema] S WITH (NOLOCK)
			LEFT JOIN [TransFerTo].[Country] C WITH (NOLOCK) ON S.[IdCountry]=C.[IdCountry]
			LEFT JOIN [TransFerTo].[Carrier] CA WITH (NOLOCK) ON S.[IdCarrier]=CA.[IdCarrier]
			LEFT JOIN [TransFerTo].[Product] P WITH (NOLOCK) ON S.[IdProduct]=P.[IdProduct]
			WHERE
				S.[IdOtherProduct]=@IdOtherProduct
				AND S.[IsDefault]=@IsDefault
				AND S.[IdGenericStatus] = CASE WHEN @ShowDisable=1 THEN S.[IdGenericStatus] ELSE 1 END
				AND S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NOT NULL
			ORDER BY S.[SchemaName]--IsDefault,IdCountry,IdCarrier,IdProduct
			--return
		END
	END


	IF @IdOtherProduct=9	-- Lunex Top Up
	BEGIN
		IF @CommissionType = 0	-- All
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
				, NULL [RetailPrice]
				, S.[BeginValue]
				, S.[EndValue]
				, S.[Commission]
				, [Operation].[fn_GetMarginByProvider](@Idprovider, S.[IdCountry], S.[IdCarrier], S.[IdProduct], S.[BeginValue], S.[EndValue])  [Margen]
				, S.[IsDefault]
				, S.[IdGenericStatus]
				, CASE
					WHEN S.[IdCountry] IS NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 0
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 1
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NULL THEN 2
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NOT NULL THEN 3
			END [CommissionType]
			, [Operation].[fn_GetFeeByProduct] (S.[IdCountry], S.[IdCarrier]) [Fee]
			FROM [TransFerTo].[Schema] S WITH (NOLOCK)
			LEFT JOIN [Operation].[Country] C WITH (NOLOCK) ON S.[IdCountry]=C.[IdCountry]
			LEFT JOIN [Operation].[Carrier] CA WITH (NOLOCK) ON S.[IdCarrier]=CA.[IdCarrier]
			WHERE
				S.[IdOtherProduct]=@IdOtherProduct
				AND S.[IsDefault]=@IsDefault
				AND S.[IdGenericStatus] = CASE WHEN @ShowDisable=1 THEN S.[IdGenericStatus] ELSE 1 END
				AND (S.[IdCountry] IS NOT NULL OR S.[IdCarrier] IS NOT NULL OR S.[IdProduct] IS NOT NULL)
			ORDER BY S.[SchemaName]--IsDefault,IdCountry,IdCarrier,IdProduct
			--return
		END

		IF @CommissionType = 1	-- Country
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
				, NULL [RetailPrice]
				, S.[BeginValue]
				, S.[EndValue]
				, S.[Commission]
				, [Operation].[fn_GetMarginByProvider](@Idprovider, S.[IdCountry], S.[IdCarrier], S.[IdProduct], S.[BeginValue], S.[EndValue]) [Margen]
				, S.[IsDefault]
				, S.[IdGenericStatus]
				, CASE
					WHEN S.[IdCountry] IS NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 0
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 1
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NULL THEN 2
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NOT NULL THEN 3
				END [CommissionType]
				, [Operation].[fn_GetFeeByProduct] (S.[IdCountry], S.[IdCarrier]) [Fee]
			FROM [TransFerTo].[Schema] S WITH (NOLOCK)
			LEFT JOIN [Operation].[Country] C WITH (NOLOCK) ON S.[IdCountry]=C.[IdCountry]
			LEFT JOIN [Operation].[Carrier] CA WITH (NOLOCK) ON S.[IdCarrier]=CA.[IdCarrier]
			WHERE
				S.[IdOtherProduct]=@IdOtherProduct
				AND [IsDefault]=@IsDefault
				AND S.[IdGenericStatus] = CASE WHEN @ShowDisable=1 THEN S.[IdGenericStatus] ELSE 1 END
				AND S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL
			ORDER BY S.[SchemaName]--IsDefault,IdCountry,IdCarrier,IdProduct
			--return
		END

		IF @CommissionType = 2	-- Carrier
		BEGIN
			SELECT
				IdSchema
				, SchemaName
				, s.IdCountry
				, Countryname
				, s.IdCarrier
				, CarrierName
				, s.IdProduct
				, null Product
				, null RetailPrice
				, BeginValue
				, EndValue
				, Commission
				, operation.[fn_GetMarginByProvider](@Idprovider,s.IdCountry,s.IdCarrier,s.IdProduct,BeginValue,EndValue) margen
				, IsDefault
				, s.IdGenericStatus
				, case 
					when s.idcountry is null and s.idcarrier is null and s.IdProduct is null then 0
					when s.idcountry is not null and s.idcarrier is null and s.IdProduct is null then 1
					when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is null then 2
					when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is not null then 3
				end CommissionType
				, [Operation].[fn_GetFeeByProduct] (S.[IdCountry], S.[IdCarrier]) [Fee]
			FROM [TransFerTo].[Schema] S WITH (NOLOCK)
			LEFT JOIN [Operation].[Country] C WITH (NOLOCK) ON S.[IdCountry]=C.[IdCountry]
			LEFT JOIN [Operation].[Carrier] CA WITH (NOLOCK) ON S.[IdCarrier]=CA.[IdCarrier]
			WHERE
				S.[IdOtherProduct]=@IdOtherProduct
				AND S.[IsDefault]=@IsDefault
				AND S.[IdGenericStatus] = CASE WHEN @ShowDisable=1 THEN S.[IdGenericStatus] ELSE 1 END
				AND S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NULL
			ORDER BY S.[SchemaName]--IsDefault,IdCountry,IdCarrier,IdProduct
			--return
		END

		IF @CommissionType = 3	-- Product
		BEGIN
			SELECT
				S.[IdSchema]
				, S.[SchemaName]
				, S.[IdCountry]
				, C.[Countryname]
				, S.[IdCarrier]
				, CA.[CarrierName]
				, S.[IdProduct]
				, NULL [Product]
				, NULL [RetailPrice]
				, S.[BeginValue]
				, S.[EndValue]
				, S.[Commission]
				, [Operation].[fn_GetMarginByProvider](@Idprovider, S.[IdCountry], S.[IdCarrier], S.[IdProduct], S.[BeginValue], S.[EndValue]) [Margen]
				, S.[IsDefault]
				, S.[IdGenericStatus]
				, CASE
					WHEN S.[IdCountry] IS NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 0
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 1
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NULL THEN 2
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NOT NULL THEN 3
				END [CommissionType]
				, [Operation].[fn_GetFeeByProduct] (S.[IdCountry], S.[IdCarrier]) [Fee]
			FROM [TransFerTo].[Schema] S WITH (NOLOCK)
			LEFT JOIN [Operation].[Country] C WITH (NOLOCK) ON S.[IdCountry]=C.[IdCountry]
			LEFT JOIN [Operation].[Carrier] CA WITH (NOLOCK) ON S.[IdCarrier]=CA.[IdCarrier]
			WHERE
				S.[IdOtherProduct]=@IdOtherProduct
				AND S.[IsDefault]=@IsDefault
				AND S.[IdGenericStatus] = CASE WHEN @ShowDisable=1 THEN S.[IdGenericStatus] ELSE 1 END
				AND S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NOT NULL
			ORDER BY S.[SchemaName]--IsDefault,IdCountry,IdCarrier,IdProduct
			--return
		END
	END

	IF @IdOtherProduct = 17		-- Regalii Top Up
	BEGIN
		
		DECLARE @RegaliiBiller NVARCHAR(MAX)
		EXEC [dbo].[st_GetGlobalAttributeValueByName] 'RegaliiBillerTypeCell', @RegaliiBiller OUTPUT

		IF @CommissionType = 0	-- All
		BEGIN
			SELECT 
				S.[IdSchema]
				, S.[SchemaName]
				, S.[IdCountry]
				, C.[CountryName]
				, S.[IdCarrier]
				, CA.[Name] [CarrierName]
				, S.[IdProduct]
				, NULL [Product]
				, NULL [RetailPrice]
				, S.[BeginValue]
				, S.[EndValue]
				, S.[Commission]
				, [Operation].[fn_GetMarginByProvider](@Idprovider, S.[IdCountry], S.[IdCarrier], S.[IdProduct], S.[BeginValue], S.[EndValue])  [Margen]
				, S.[IsDefault]
				, S.[IdGenericStatus]
				, CASE
					WHEN S.[IdCountry] IS NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 0
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 1
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NULL THEN 2
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NOT NULL THEN 3
			END [CommissionType]
			, 0 AS [Fee]
			FROM [TransFerTo].[Schema] S WITH (NOLOCK)
			LEFT JOIN [dbo].[Country] C WITH (NOLOCK) ON S.[IdCountry]=C.[IdCountry]
			LEFT JOIN (
						SELECT [IdBiller], [Name], [IdCountry]
						FROM [Regalii].[Billers] WITH (NOLOCK)
						WHERE [BillerType] = @RegaliiBiller
					) CA ON S.[IdCarrier]=CA.[IdBiller]
			WHERE
				S.[IdOtherProduct]=@IdOtherProduct
				AND S.[IsDefault]=@IsDefault
				AND S.[IdGenericStatus] = CASE WHEN @ShowDisable=1 THEN S.[IdGenericStatus] ELSE 1 END
				AND (S.[IdCountry] IS NOT NULL OR S.[IdCarrier] IS NOT NULL)
			ORDER BY S.[SchemaName]
		END

		IF @CommissionType = 1	-- Country
		BEGIN
			SELECT 
				S.[IdSchema]
				, S.[SchemaName]
				, S.[IdCountry]
				, C.[CountryName]
				, S.[IdCarrier]
				, CA.[Name] [CarrierName]
				, S.[IdProduct]
				, NULL [Product]
				, NULL [RetailPrice]
				, S.[BeginValue]
				, S.[EndValue]
				, S.[Commission]
				, [Operation].[fn_GetMarginByProvider](@Idprovider, S.[IdCountry], S.[IdCarrier], S.[IdProduct], S.[BeginValue], S.[EndValue])  [Margen]
				, S.[IsDefault]
				, S.[IdGenericStatus]
				, CASE
					WHEN S.[IdCountry] IS NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 0
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 1
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NULL THEN 2
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NOT NULL THEN 3
			END [CommissionType]
			, 0 AS [Fee]
			FROM [TransFerTo].[Schema] S WITH (NOLOCK)
			LEFT JOIN [dbo].[Country] C WITH (NOLOCK) ON S.[IdCountry]=C.[IdCountry]
			LEFT JOIN (
						SELECT [IdBiller], [Name], [IdCountry]
						FROM [Regalii].[Billers] WITH (NOLOCK)
						WHERE [BillerType] = @RegaliiBiller
					) CA ON S.[IdCarrier]=CA.[IdBiller]
			WHERE
				S.[IdOtherProduct]=@IdOtherProduct
				AND S.[IsDefault]=@IsDefault
				AND S.[IdGenericStatus] = CASE WHEN @ShowDisable=1 THEN S.[IdGenericStatus] ELSE 1 END
				AND S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NULL
			ORDER BY S.[SchemaName]
		END

		IF @CommissionType = 2	-- Carrier
		BEGIN
			SELECT 
				S.[IdSchema]
				, S.[SchemaName]
				, S.[IdCountry]
				, C.[CountryName]
				, S.[IdCarrier]
				, CA.[Name] [CarrierName]
				, S.[IdProduct]
				, NULL [Product]
				, NULL [RetailPrice]
				, S.[BeginValue]
				, S.[EndValue]
				, S.[Commission]
				, [Operation].[fn_GetMarginByProvider](@Idprovider, S.[IdCountry], S.[IdCarrier], S.[IdProduct], S.[BeginValue], S.[EndValue])  [Margen]
				, S.[IsDefault]
				, S.[IdGenericStatus]
				, CASE
					WHEN S.[IdCountry] IS NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 0
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NULL AND S.[IdProduct] IS NULL THEN 1
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NULL THEN 2
					WHEN S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL AND S.[IdProduct] IS NOT NULL THEN 3
			END [CommissionType]
			, 0 AS [Fee]
			FROM [TransFerTo].[Schema] S WITH (NOLOCK)
			LEFT JOIN [dbo].[Country] C WITH (NOLOCK) ON S.[IdCountry]=C.[IdCountry]
			LEFT JOIN (
						SELECT [IdBiller], [Name], [IdCountry]
						FROM [Regalii].[Billers] WITH (NOLOCK)
						WHERE [BillerType] = @RegaliiBiller
					) CA ON S.[IdCarrier]=CA.[IdBiller]
			WHERE
				S.[IdOtherProduct]=@IdOtherProduct
				AND S.[IsDefault]=@IsDefault
				AND S.[IdGenericStatus] = CASE WHEN @ShowDisable=1 THEN S.[IdGenericStatus] ELSE 1 END
				AND S.[IdCountry] IS NOT NULL AND S.[IdCarrier] IS NOT NULL
			ORDER BY S.[SchemaName]
		END

	END


