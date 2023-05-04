CREATE PROCEDURE [dbo].[st_GetOtherProductsSearchTicket] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    SELECT 
		[IdOtherProducts]
		,[Description]
		,[Visible]      
	FROM [dbo].[OtherProducts]
	where 
		Visible = 1
		or IdOtherProducts = 15
	ORDER BY Description asc
END

