CREATE PROCEDURE [Corp].[st_GetBillPaymentNote]
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
