-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[st_GetComission] 
	@idCommission int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [IdCommissionByOtherProducts], [IdOtherProducts], [CommissionName], [DateOfLastChange], [EnterByIdUser], [IdOtherProductCommissionType], [IsEnable]
	FROM [dbo].[CommissionByOtherProducts] WITH(NOLOCK)
	WHERE [IdCommissionByOtherProducts] = @idCommission

END

