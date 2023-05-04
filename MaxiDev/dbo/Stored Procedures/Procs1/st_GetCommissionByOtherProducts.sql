
CREATE PROCEDURE [dbo].[st_GetCommissionByOtherProducts]
(
    @IdOtherProduct int
)
as
    select IdCommissionByOtherProducts,IdOtherProducts,CommissionName,DateOfLastChange,EnterByIdUser,IdOtherProductCommissionType 
	from CommissionByOtherProducts WITH(NOLOCK)
	--where IdOtherProducts=@IdOtherProduct
