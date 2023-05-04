CREATE FUNCTION [Operation].[fn_GetMarginByProvider]
(
    @IdProvider INT = NULL,
    @IdCountry INT = NULL,
    @IdCarrier INT = NULL,
    @IdProduct INT = NULL,
    @Retail1 MONEY = NULL,
    @Retail2 MONEY = NULL
)
RETURNS MONEY
AS
BEGIN
	DECLARE @Result MONEY

	DECLARE @IdOtherProduct INT
	SET @Idprovider = ISNULL(@Idprovider,2)
	SET @IdOtherProduct =	CASE
								WHEN @IdProvider=2 THEN 7	-- TransferTo Top Up
								WHEN @IdProvider=3 THEN 9	-- Lunex Top Up
								WHEN @IdProvider=5 THEN 17	-- Regalii Top Up
							ELSE 0 END

	IF @IdOtherProduct=7	-- TransferTo Top Up
	BEGIN
		SELECT @Result = ROUND(SUM([Margin])/COUNT(1),2)
		FROM [TransFerTo].[Product] P WITH (NOLOCK)
		WHERE P.[IdCountry] = ISNULL(@IdCountry,P.[IdCountry])
		AND P.[IdCarrier] = ISNULL(@IdCarrier, P.[IdCarrier])
		AND P.[IdProduct] = ISNULL(@IdProduct, P.[IdProduct])
		AND P.[RetailPrice] >= ISNULL(@Retail1, P.[RetailPrice])
		AND P.[RetailPrice] <= ISNULL(@Retail2, P.[RetailPrice])
		AND P.[IdGenericStatus]=1
	END

	IF @IdOtherProduct=9	-- Lunex Top Up
	BEGIN
		SELECT @Result = ROUND(SUM([Margin])/COUNT(1),2)
		FROM [Lunex].[Product] P WITH (NOLOCK)
		WHERE [IdCountry]=ISNULL(@IdCountry,[IdCountry])
			AND P.[IdCarrier]=ISNULL(@IdCarrier, P.[IdCarrier])
			AND P.[IdGenericstatus]=1
	END

	IF @IdOtherProduct=17	-- Regalii Top Up
	BEGIN
		
		DECLARE @RegaliiBiller NVARCHAR(MAX)
		SET @RegaliiBiller = [dbo].[GetGlobalAttributeByName]('RegaliiBillerTypeCell')

		SELECT @Result = ROUND(SUM(RB.[TopUpCommission])/COUNT(1),2)
		FROM [Regalii].[Billers] RB WITH (NOLOCK)
		WHERE [IdCountry]=ISNULL(@IdCountry,[IdCountry])
			AND RB.[IdBiller]=ISNULL(@IdCarrier, RB.[IdBiller])
			AND RB.[BillerType] = @RegaliiBiller
			
	END

	RETURN ISNULL(@Result,0)

END
