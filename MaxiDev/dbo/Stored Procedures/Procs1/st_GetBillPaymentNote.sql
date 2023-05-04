/********************************************************************
<Author>jresendiz</Author>
<app>Corporate </app>
<Description></Description>

<ChangeLog>
<log Date="26/12/2018" Author="jresendiz"> Creado </log>
</ChangeLog>

*********************************************************************/
CREATE PROCEDURE [dbo].[st_GetBillPaymentNote] 
	@IdBillPayment int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [IdBillPaymentNote], [IdBillPayment], [IdUser], [Note], [LastChange_LastUserChange], [LastChange_LastDateChange], [LastChange_LastIpChange], [LastChange_LastNoteChange]
	FROM [dbo].[BillPaymentNotes] WITH(NOLOCK)
	WHERE IdBillPayment = @IdBillPayment

END
