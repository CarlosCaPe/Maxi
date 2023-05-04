-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-03-29
-- Description:	Return margin detail top up product // This stored is used in BackOffice (Billpayments) - TopUp Scheme
-- =============================================
CREATE PROCEDURE [Operation].[st_GetMarginDetail]
(
    @IdProvider INT = NULL,
    @IdCountry INT = NULL,
    @IdCarrier INT = NULL,
    @IdProduct INT = NULL,
    @Retail1 MONEY = NULL,
    @Retail2 MONEY = NULL
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
			P.[IdCountry]
			, C.[CountryName]
			, P.[IdCarrier]
			, CA.[CarrierName]
			, P.[IdProduct]
			, P.[Product]
			, P.[RetailPrice]
			, P.[Margin]
		FROM [TransFerTo].[Product] P WITH (NOLOCK)
		JOIN [TransFerTo].[Country] C WITH (NOLOCK) ON P.[IdCountry]=C.[IdCountry]
		JOIN [TransFerTo].[Carrier] CA WITH (NOLOCK) ON CA.[IdCarrier]=P.[IdCarrier]
		WHERE
			P.[IdCountry]=ISNULL(@IdCountry, P.[IdCountry])
			AND P.[IdCarrier]=ISNULL(@IdCarrier,P.[IdCarrier])
			AND P.[IdProduct]=ISNULL(@IdProduct,P.[IdProduct])
			AND P.[RetailPrice]>=ISNULL(@Retail1,P.[RetailPrice])
			AND P.[RetailPrice]<=ISNULL(@Retail2,P.[RetailPrice])
			AND P.[IdGenericStatus]=1
	END


	IF @IdOtherProduct=9	-- Lunex Top Up
	BEGIN
		SELECT
			P.[IdCountry]
			, C.[CountryName]
			, P.[IdCarrier]
			, CA.[CarrierName]
			, NULL [IdProduct]
			, NULL [Product]
			, NULL [RetailPrice]
			, P.[Margin]
		FROM [Lunex].[Product] P WITH (NOLOCK)
		JOIN [Operation].[Country] C WITH (NOLOCK) ON P.[IdCountry]=C.[IdCountry]
		JOIN [Operation].[Carrier] CA WITH (NOLOCK) ON CA.[IdCarrier]=P.[IdCarrier]
		WHERE
			P.[IdCountry]=ISNULL(@IdCountry, P.[IdCountry])
			AND P.[IdCarrier]=ISNULL(@IdCarrier, P.[IdCarrier])
			AND P.[IdGenericstatus]=1
	END

	IF @IdOtherProduct = 17	-- Regalii Top Up
	BEGIN
		
		DECLARE @RegaliiBiller NVARCHAR(MAX)
		EXEC [dbo].[st_GetGlobalAttributeValueByName] 'RegaliiBillerTypeCell', @RegaliiBiller OUTPUT

		SELECT
			RB.[IdCountry]
			, C.[CountryName]
			, RB.[IdBiller] [IdCarrier]
			, RB.[Name] [CarrierName]
			, NULL [IdProduct]
			, NULL [Product]
			, NULL [RetailPrice]
			, RB.[TopUpCommission] [Margin]
		FROM [Regalii].[Billers] RB WITH (NOLOCK)
		JOIN [dbo].[Country] C WITH (NOLOCK) ON RB.[IdCountry]=C.[IdCountry]
		WHERE
			RB.[IdCountry]=ISNULL(@IdCountry, RB.[IdCountry])
			AND RB.[IdBiller]=ISNULL(@IdCarrier, RB.[IdBiller])
			AND RB.[BillerType] = @RegaliiBiller

	END