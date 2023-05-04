
-- ============================================= 
-- Author:		Francisco Lara
-- Create date: 2016-03-29
-- Description:	Return carriers for top scheme // This stored is used in BackOffice (Billpayments) - TopUp Scheme
-- =============================================
CREATE PROCEDURE [Operation].[st_GetCarrier]
(
    @IdProvider INT = NULL,
    @IdCountry INT = NULL    
)
AS

	DECLARE @IdOtherProduct INT
	SET @Idprovider = ISNULL(@Idprovider,2)
	SET @IdOtherProduct =	CASE
								WHEN @IdProvider=2 THEN 7	-- TransferTo Top Up
								WHEN @IdProvider=3 THEN 9	-- Lunex Top Up
								WHEN @IdProvider=5 THEN 17	-- Regalii Top Up
							ELSE 0 END

	IF @IdOtherProduct=7	-- TransferTo Top Up
	BEGIN
		SELECT DISTINCT
			C.[IdCarrier]
			, C.[CarrierName]
			, C.[IdCarrierTTo] [IdCarrierProvider]
			, C.[IdGenericStatus]
			, 0 AS Fee
		FROM [TransFerTo].[Carrier] C WITH (NOLOCK)
		WHERE C.[IdCountry]=ISNULL(@IdCountry,0)
			AND C.[IdGenericStatus] = 1
		GROUP BY C.[IdCarrier], C.[CarrierName], C.[IdCarrierTTo], C.[IdGenericStatus] 
		HAVING COUNT(1)>0
		ORDER BY C.[CarrierName]
	END

	IF @IdOtherProduct=9	-- Lunex Top Up
	BEGIN
		SELECT DISTINCT
			C.[IdCarrier]
			, CR.[CarrierName]
			, C.[IdCarrier] [IdCarrierProvider]
			, C.[IdGenericstatus]
			, [Operation].[fn_GetFeeByProduct] (@IdCountry,  C.[IdCarrier]) [Fee]
		FROM [Lunex].[Product] C WITH (NOLOCK)
		JOIN [Operation].[Carrier] CR WITH (NOLOCK) ON C.[IdCarrier]=CR.[IdCarrier] AND CR.[Provider]=@idprovider AND CR.[IdGenericStatus] = 1
		WHERE C.[IdCountry]=ISNULL(@IdCountry,0)
			AND C.[IdGenericstatus] = 1
		GROUP BY C.[IdCarrier], CR.[CarrierName], C.[IdCarrier], C.[IdGenericstatus] 
		HAVING COUNT(1)>0
		ORDER BY CR.[CarrierName]
	END

	IF @IdOtherProduct = 17 -- Regalii Top Up
	BEGIN
		
		DECLARE @RegaliiBiller NVARCHAR(MAX)
		EXEC [dbo].[st_GetGlobalAttributeValueByName] 'RegaliiBillerTypeCell', @RegaliiBiller OUTPUT

		SELECT DISTINCT
			RB.[IdBiller] [IdCarrier]
			, RB.[Name] [CarrierName]
			, RB.[IdBiller] [IdCarrierProvider]
			, 1 [IdGenericstatus]
			, 0 AS Fee
		FROM [Regalii].[Billers] RB WITH (NOLOCK)
		WHERE RB.[IdCountry]=ISNULL(@IdCountry,0)
			AND RB.[BillerType] = @RegaliiBiller
		GROUP BY RB.[IdBiller], RB.[Name], RB.[IdBiller]
		HAVING COUNT(1)>0
		ORDER BY RB.[Name]

	END
