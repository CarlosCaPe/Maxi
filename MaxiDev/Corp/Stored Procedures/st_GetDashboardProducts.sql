Create PROCEDURE [Corp].[st_GetDashboardProducts]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT 
		[IdOtherProducts]
		,[Description]      
	FROM [dbo].[OtherProducts] WITH(NOLOCK)
	where 
		Visible = 1
		and IdOtherProducts not in (8)
	ORDER BY Description asc
END
