CREATE PROCEDURE [Corp].[st_GetFee] 
	@fee int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT [IdFeeByOtherProducts], [IdOtherProducts], [FeeName], [DateOfLastChange], [EnterByIdUser], [IdOtherProductCommissionType], [IsEnable] 
	FROM [dbo].[FeeByOtherProducts] WITH(NOLOCK) 
	WHERE [IdFeeByOtherProducts] = @fee

END
