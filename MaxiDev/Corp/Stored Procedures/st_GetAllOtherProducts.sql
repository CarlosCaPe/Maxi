CREATE PROCEDURE [Corp].[st_GetAllOtherProducts] (@IdAgent INT) AS

--select * from AgentBillPaymentInfo where IdAgent = @IdAgent
	SELECT [IdAgent], [AmountForClassF], [IdFeeByotherProducts], [IdCommissionByOtherProducts]
	FROM [dbo].[AgentBillPaymentInfo] WITH (NOLOCK) WHERE [IdAgent] = @IdAgent

--select * from AgentPureMinutesInfo where IdAgent = @IdAgent
	SELECT [IdAgent], [IdFeeByOtherProducts], [IdCommissionByOtherProducts]
	FROM [dbo].[AgentPureMinutesInfo] WITH (NOLOCK) WHERE [IdAgent] = @IdAgent

--select * from AgentPureMinutesTopUpInfo where IdAgent = @IdAgent
	SELECT [IdAgent], [IdFeeByOtherProducts], [IdCommissionByOtherProducts]
	FROM [dbo].[AgentPureMinutesTopUpInfo] WITH (NOLOCK) WHERE [IdAgent] = @IdAgent

--select AP.*, FP.IdOtherProductCommissionType as FeeType, CP.IdOtherProductCommissionType as CommissionType from AgentOtherProductInfo AP 
--left join FeeByOtherProducts FP on FP.IdFeeByOtherProducts = AP.IdFeeByOtherProducts
--left join CommissionByOtherProducts CP on CP.IdCommissionByOtherProducts = AP.IdCommissionByOtherProducts  where AP.IdAgent  = @IdAgent

SELECT
	AP.[IdAgentOtherProductInfo]
	,AP.[IdAgent]
	,AP.[IdOtherProduct]
	,AP.[AmountForAgent]
	,AP.[IdFeeByOtherProducts]
	,AP.[IdCommissionByotherProducts]
	,FP.[IdOtherProductCommissionType] FeeType
	,CP.IdOtherProductCommissionType CommissionType
	FROM [dbo].[AgentOtherProductInfo] AP WITH (NOLOCK)
	LEFT JOIN [dbo].[FeeByOtherProducts] FP WITH (NOLOCK) ON AP.[IdFeeByOtherProducts] = FP.IdFeeByOtherProducts
	LEFT JOIN [dbo].[CommissionByOtherProducts] CP WITH (NOLOCK) ON AP.[IdCommissionByOtherProducts] = CP.[IdCommissionByOtherProducts]
	WHERE AP.[IdAgent] = @IdAgent
