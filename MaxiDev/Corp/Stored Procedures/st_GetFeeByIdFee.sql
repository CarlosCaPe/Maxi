CREATE PROCEDURE [Corp].[st_GetFeeByIdFee]
(
	@IdFee int = null
)
AS  

Set nocount on;
Begin try
		Select IdFee, FeeName from Fee with(nolock) where IdFee = ISNULL(@IdFee, IdFee)
	if(@IdFee != 0 and @IdFee is not null)
		Select IdFeeDetail, Fee, FromAmount, ToAmount, IsFeePercentage 
		from FeeDetail with(nolock) where IdFee = @IdFee
End try
Begin Catch
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_GetFeeByIdFee',Getdate(),@ErrorMessage);
End catch
