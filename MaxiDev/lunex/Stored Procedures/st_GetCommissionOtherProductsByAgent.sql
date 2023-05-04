-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-03-07
-- Description:	Returns commissions for other products by Agent Id // This stored is used in MaxiBackOffice
-- =============================================
CREATE PROCEDURE [lunex].[st_GetCommissionOtherProductsByAgent]
(
    @IdAgent INT
)
AS
	--WAITFOR DELAY '00:00:20'
	SELECT
		[IdOtherProducts] [IdOtherProduct]
		, [IdCommissionByOtherProducts]
		, [IdAgentOtherProductInfo]
	FROM [dbo].[OtherProducts] O WITH (NOLOCK)
	LEFT JOIN (
		SELECT
			IdAgentOtherProductInfo
			, idotherproduct
			, idcommissionbyotherproducts
		FROM [dbo].[AgentOtherProductInfo] AP WITH (NOLOCK)
		WHERE [IdAgent]=@IdAgent
			AND [IdOtherProduct] IN (10,11,12,13,16)
		) T ON T.[IdOtherProduct] = O.[IdOtherProducts]
	WHERE [IdOtherProducts] IN (10,11,13,16)
	/*WHERE [IdOtherProducts] IS NOT NULL
	  AND [IdCommissionByOtherProducts] IS NOT NULL*/


