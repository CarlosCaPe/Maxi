CREATE FUNCTION [Operation].[fn_GetFeeByProduct]
(
    @IdCountry INT = NULL,
    @IdCarrier INT = NULL
)
RETURNS MONEY
AS
-- =============================================
-- Author:		Dario Almeida
-- Create date: 2017-05-30
-- Description: Returns Fee for Lunex products
--<log Date="24/12/2018" Author="jmolina">Add with(nolock)</log>
BEGIN
	DECLARE @Result MONEY

	SELECT @Result = ISNULL(SK.FEE,0) --ROUND(SUM([Margin])/COUNT(1),2)
	FROM [Lunex].[Product] P WITH (NOLOCK)
	LEFT JOIN [Operation].[ProductsSKUFeeBased] SK WITH (NOLOCK) ON P.SKU = SK. SKU
	WHERE [IdCountry]=ISNULL(@IdCountry,[IdCountry])
		AND P.[IdCarrier]=ISNULL(@IdCarrier, P.[IdCarrier])
		AND P.[IdGenericstatus]=1
	
	RETURN ISNULL(@Result,0)
END