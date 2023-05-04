CREATE PROCEDURE [Corp].[st_GetTickets] 
	@IdTicket INT,
	@IdProduct INT,
	@IdTransaction INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF (@IdTicket > 0)
		BEGIN
			SELECT T.[IdTicket], T.[TicketDate], T.[IdUser], T.[IdProduct], T.[IdTransaction], T.[Note], T.[IdStatus], T.[IdPriority], T.[IdTicketCloseReason], T.[LastChange_LastUserChange], T.[LastChange_LastDateChange], 
				T.[LastChange_LastIpChange], T.[LastChange_LastNoteChange], T.[Reference], T.[OperationDate], A.[IdAgent], [ClosedDate], A.AgentCode, A.AgentName
			FROM [dbo].[Tickets] T WITH(NOLOCK)
			JOIN [dbo].[Agent] A WITH(NOLOCK) ON A.IdAgent = T.IdAgent
			WHERE [IdTicket] = @IdTicket
		END
	ELSE IF (@IdProduct > 0 AND @IdTransaction > 0)
		BEGIN 
		SELECT T.[IdTicket], T.[TicketDate], T.[IdUser], T.[IdProduct], T.[IdTransaction], T.[Note], T.[IdStatus], T.[IdPriority], T.[IdTicketCloseReason], T.[LastChange_LastUserChange], T.[LastChange_LastDateChange], 
				T.[LastChange_LastIpChange], T.[LastChange_LastNoteChange], T.[Reference], T.[OperationDate], A.[IdAgent], [ClosedDate], A.AgentCode, A.AgentName
			FROM [dbo].[Tickets] T WITH(NOLOCK)
			JOIN [dbo].[Agent] A WITH(NOLOCK) ON A.IdAgent = T.IdAgent
			WHERE IdProduct = @IdProduct AND IdTransaction = @IdTransaction
		END
	ELSE 
		BEGIN
			SELECT T.[IdTicket], T.[TicketDate], T.[IdUser], T.[IdProduct], T.[IdTransaction], T.[Note], T.[IdStatus], T.[IdPriority], T.[IdTicketCloseReason], T.[LastChange_LastUserChange], T.[LastChange_LastDateChange], 
				T.[LastChange_LastIpChange], T.[LastChange_LastNoteChange], T.[Reference], T.[OperationDate], A.[IdAgent], [ClosedDate], A.AgentCode, A.AgentName
			FROM [dbo].[Tickets] T WITH(NOLOCK)
			JOIN [dbo].[Agent] A WITH(NOLOCK) ON A.IdAgent = T.IdAgent
		END
	 
END 
