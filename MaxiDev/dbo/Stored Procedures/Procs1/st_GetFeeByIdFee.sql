/********************************************************************
<Author>smacias</Author>
<app>??</app>
<Description>??</Description>

<ChangeLog>
<log Date="06/12/2018" Author="smacias"> Creado </log>
</ChangeLog>

*********************************************************************/
CREATE procedure [dbo].[st_GetFeeByIdFee]
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
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetFeeByIdFee',Getdate(),@ErrorMessage);
End catch
