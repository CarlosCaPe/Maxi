CREATE PROCEDURE [dbo].[st_GetPriorities] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [IdTicketPriority], [Description], [Value]
    FROM [dbo].[TicketPriorities] WITH(NOLOCK)

END 



