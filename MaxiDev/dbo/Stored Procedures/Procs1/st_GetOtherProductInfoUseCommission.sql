
create Procedure [dbo].[st_GetOtherProductInfoUseCommission] (
	@IdCommissionByOtherProducts int,
	@IdOtherProduct int,
    @Total int out
)            
AS            
	if(@IdOtherProduct = 1)
		select @Total = (select count(IdAgent) from AgentBillPaymentInfo  where IdAgent in (select IdAgent from AgentProducts where IdOtherProducts = @IdOtherProduct) and IdCommissionByOtherProducts = @IdCommissionByOtherProducts)
	if(@IdOtherProduct = 5)
		select @Total = (select count(IdAgent) from AgentPureMinutesInfo  where IdAgent in (select IdAgent from AgentProducts where IdOtherProducts = @IdOtherProduct)and IdCommissionByOtherProducts = @IdCommissionByOtherProducts)
	if(@IdOtherProduct > 6)
		select @Total = (select count(IdAgent) from AgentOtherProductInfo where IdAgent in (select IdAgent from AgentProducts where IdOtherProducts = @IdOtherProduct) and IdCommissionByOtherProducts = @IdCommissionByOtherProducts)

set @Total=isnull(@Total,0)
