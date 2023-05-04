--select * from FeeByOtherProducts

create procedure st_GetFeeByOtherProducts
(
    @IdOtherProduct int
)
as
    select IdFeeByOtherProducts,IdOtherProducts,FeeName,DateOfLastChange,EnterByIdUser,IdOtherProductCommissionType from FeeByOtherProducts where IdOtherProducts=@IdOtherProduct