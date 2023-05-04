CREATE PROCEDURE [Corp].[st_GetAllCommissionsV2]
	@idProduct int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF(@idProduct = 0)
	BEGIN
	SELECT [IdCommissionByOtherProducts], [IdOtherProducts], [CommissionName], [DateOfLastChange], [EnterByIdUser], [IdOtherProductCommissionType], [IsEnable]
		FROM [dbo].[CommissionByOtherProducts] WITH(NOLOCK)
		WHERE [IdOtherProducts] != 9 AND 
		[IdOtherProducts] != 10 AND 
		[IdOtherProducts] != 11 AND 
		[IdOtherProducts] != 13 AND 
		[IdOtherProducts] != 16
		order by CommissionName asc
	END
	ELSE 
	BEGIN
		SELECT [IdCommissionByOtherProducts], [IdOtherProducts], [CommissionName], [DateOfLastChange], [EnterByIdUser], [IdOtherProductCommissionType], [IsEnable]
		FROM [dbo].[CommissionByOtherProducts] WITH(NOLOCK)
		WHERE [IdOtherProducts] = @idProduct
		order by CommissionName asc
	END

    

END
