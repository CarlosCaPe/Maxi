CREATE PROCEDURE [Corp].[st_GetFees] 
	@idProduct int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET @idProduct = ISNULL(@idProduct, 0)

	IF(@idProduct>0)
		BEGIN
		SELECT [IdFeeByOtherProducts], [IdOtherProducts], [FeeName], [DateOfLastChange], [EnterByIdUser], [IdOtherProductCommissionType] , [IsEnable]
		FROM [dbo].[FeeByOtherProducts] WITH(NOLOCK) 
		WHERE [IdOtherProducts] = @idProduct
		END
	ELSE 
		BEGIN
			SELECT [IdFeeByOtherProducts], [IdOtherProducts], [FeeName], [DateOfLastChange], [EnterByIdUser], [IdOtherProductCommissionType] , [IsEnable]
			FROM [dbo].[FeeByOtherProducts] WITH(NOLOCK) 
		END
END
