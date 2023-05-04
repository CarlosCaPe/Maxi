CREATE procedure [Corp].[st_GetCommissionByOtherProducts]
(
	@IdOtherProduct int
)
AS  

Set nocount on;
Begin try
		SET @IdOtherProduct = ISNULL(@IdOtherProduct, 0)

	IF(@IdOtherProduct>0)
		BEGIN
			select IdCommissionByOtherProducts,IdOtherProducts,CommissionName,DateOfLastChange,EnterByIdUser,IdOtherProductCommissionType 
			from CommissionByOtherProducts with(nolock)
			where IdOtherProducts=@IdOtherProduct -- fix regalii commission agent
		END
	ELSE 
		BEGIN
			select IdCommissionByOtherProducts,IdOtherProducts,CommissionName,DateOfLastChange,EnterByIdUser,IdOtherProductCommissionType 
			from CommissionByOtherProducts with(nolock)
		END
End try
Begin Catch    
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_GetCommissionByOtherProducts',Getdate(),@ErrorMessage);
End catch