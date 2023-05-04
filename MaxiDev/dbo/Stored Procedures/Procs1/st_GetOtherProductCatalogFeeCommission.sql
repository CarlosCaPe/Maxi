CREATE procedure st_GetOtherProductCatalogFeeCommission
(
    @IdOtherProduct int 
)
as

select IdOtherProductCommissionType,CommissionTypeName into #temp from OtherProductCommissionType where IdOtherProduct = @IdOtherProduct

select IdOtherProductCommissionType,CommissionTypeName from #temp

select IdFeeByOtherProducts,FeeName,IdOtherProductCommissionType from FeeByOtherProducts where IdOtherProducts = @IdOtherProduct and IdOtherProductCommissionType in (select IdOtherProductCommissionType from #temp)
select IdCommissionByOtherProducts,CommissionName,IdOtherProductCommissionType from CommissionByOtherProducts where IdOtherProducts = @IdOtherProduct and IdOtherProductCommissionType in (select IdOtherProductCommissionType from #temp)
