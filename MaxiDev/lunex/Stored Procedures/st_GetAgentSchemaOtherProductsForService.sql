-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-03-07
-- Description:	Return Lunex commission by product service // This stored is used in MaxiBackOffice (LunexWCFService)
-- =============================================
CREATE PROCEDURE [Lunex].[st_GetAgentSchemaOtherProductsForService]
(
    @idagent INT,
    @skutype NVARCHAR(MAX),
    @SKU NVARCHAR(1000)
)
AS
	DECLARE @IdOtherProduct INT = 0
	DECLARE @IdCommissionByOtherProducts INT

	IF @SKUType = 'Pinless' AND @SKU='1021'
		SET @SKUType='PinlessU'

	SELECT @IdOtherProduct=[IdOtherProduct] FROM [Lunex].[SKUTypeToOtherProduct] WITH (NOLOCK) WHERE [SKUType]=@skutype

	SELECT @IdCommissionByOtherProducts=[IdCommissionByOtherProducts] FROM [dbo].[AgentOtherProductInfo] WITH (NOLOCK) WHERE [IdAgent]=@idagent AND [IdOtherProduct]=@IdOtherProduct

	--select * from dbo.CommissionByOtherProducts   where IdCommissionByOtherProducts=@IdCommissionByOtherProducts

	SELECT
		[IdCommissionDetailByProvider]
		, [IdCommissionByOtherProducts]
		, [FromAmount]
		, [ToAmount]
		, [AgentCommissionInPercentage]
		, [CorporateCommissionInPercentage]
		,ExtraAmount
	FROM [dbo].[CommissionDetailByOtherProducts] WITH (NOLOCK)
	WHERE [IdCommissionByOtherProducts] = @IdCommissionByOtherProducts

	