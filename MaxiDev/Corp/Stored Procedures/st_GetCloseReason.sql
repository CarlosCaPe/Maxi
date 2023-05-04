CREATE PROCEDURE [Corp].[st_GetCloseReason] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT [IdTicketCloseReason], [Description], [descriptionES]
	FROM [dbo].[TicketCloseReasons] WITH(NOLOCK)

END 
