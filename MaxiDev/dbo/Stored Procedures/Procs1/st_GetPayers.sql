CREATE PROCEDURE [dbo].[st_GetPayers] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [IdPayer], [PayerName], [PayerCode], [Folio], [IdGenericStatus], [DateOfLastChange], [EnterByIdUser]
    FROM [dbo].[Payer] WITH(NOLOCK)

END



