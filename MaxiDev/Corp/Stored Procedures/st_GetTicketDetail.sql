CREATE PROCEDURE [Corp].[st_GetTicketDetail] 
	@IdTicket INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT [IdTicketDetails], [IdTicket], [NoteDate], [Note], [IdUser], [LastChange_LastUserChange], [LastChange_LastDateChange], [LastChange_LastIpChange], [LastChange_LastNoteChange]
	FROM [dbo].[TicketDetails] WITH(NOLOCK)
	WHERE IdTicket = @IdTicket
END 
