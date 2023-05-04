/********************************************************************
<Author>jresendiz</Author>
<app>Corporate </app>
<Description></Description>

<ChangeLog>
<log Date="10/12/2018" Author="jresendiz"> Creado </log>
<log Date="12/05/2019" Author="esalazar"> IsEnable </log>
</ChangeLog>

*********************************************************************/
CREATE PROCEDURE [dbo].[st_GetFee] 
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

