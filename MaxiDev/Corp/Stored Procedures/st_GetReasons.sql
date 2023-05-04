CREATE PROCEDURE [Corp].[st_GetReasons] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [IdTicketCloseReason], [Description]
    FROM [dbo].[TicketCloseReasons] WITH(NOLOCK)

END 


