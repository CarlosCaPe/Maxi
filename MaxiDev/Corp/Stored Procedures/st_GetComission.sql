CREATE PROCEDURE [Corp].[st_GetComission] 
	@idCommission int
AS
/********************************************************************
<Author> ??? </Author>
<app> Corporative </app>
<Description> Obtener la informacion de una comision</Description>

<ChangeLog>
</ChangeLog>
*********************************************************************/
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [IdCommissionByOtherProducts], [IdOtherProducts], [CommissionName], [DateOfLastChange], [EnterByIdUser], [IdOtherProductCommissionType], [IsEnable]
	FROM [dbo].[CommissionByOtherProducts] WITH(NOLOCK)
	WHERE [IdCommissionByOtherProducts] = @idCommission

END
