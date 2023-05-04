--select * from FeedetailByOtherProducts

create procedure st_GetFeeDetailByOtherProducts
(
    @IdFeeByOtherProducts int
)
as
    select IdFeeDetailByOtherProductsr,IdFeeByOtherProducts,FromAmount,ToAmount,Fee,DateOfLastChange,EnterByIdUser,IsFeePercentage from FeedetailByOtherProducts where IdFeeByOtherProducts=@IdFeeByOtherProducts