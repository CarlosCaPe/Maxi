/********************************************************************
<Author>jresendiz</Author>
<app>Corporate </app>
<Description></Description>

<ChangeLog>
<log Date="26/12/2018" Author="jresendiz"> Creado </log>
</ChangeLog>

*********************************************************************/
CREATE PROCEDURE [dbo].[st_GetBillPaymentDetail] 
	@IdBillPayment int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT [IdBillPaymentDetail], [Code], [Description], [IdBillPayment]
	FROM [dbo].[BillPaymentDetails] WITH(NOLOCK)
	WHERE IdBillPayment = @IdBillPayment

END
