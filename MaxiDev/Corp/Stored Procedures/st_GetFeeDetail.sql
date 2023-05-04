CREATE PROCEDURE [Corp].[st_GetFeeDetail] 
	@fee int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [IdFeeDetailByOtherProductsr], [IdFeeByOtherProducts], [FromAmount], [ToAmount], [Fee], [DateOfLastChange], [EnterByIdUser], [IsFeePercentage]
	FROM [dbo].[FeeDetailByOtherProducts] WITH(NOLOCK)
	WHERE [IdFeeByOtherProducts] = @fee

END
