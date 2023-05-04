CREATE PROCEDURE [dbo].[st_GetTicketsV2] 
	@IdProduct INT,
	@IdTransaction INT = 0,
	@IdStatus INT,
	@FromDate datetime,
	@ToDate datetime
AS
-- =============================================
-- Author:		Oscar Murillo
-- Create date: 2019-09-10
-- Description:	Se creo nuevo sp para agilizar la carga de los registros haciendo el filtrado desde sql 
-- =============================================
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF (@IdProduct = 0) SET @IdProduct = NULL
	IF (@IdTransaction = 0) SET @IdTransaction = NULL
	IF (@IdStatus = 0) SET @IdStatus = NULL

			SELECT T.[IdTicket], T.[TicketDate], T.[IdUser], T.[IdProduct], T.[IdTransaction], T.[Note], T.[IdStatus], T.[IdPriority], T.[IdTicketCloseReason], T.[LastChange_LastUserChange], T.[LastChange_LastDateChange], 
				T.[LastChange_LastIpChange], T.[LastChange_LastNoteChange], T.[Reference], T.[OperationDate], A.[IdAgent], [ClosedDate], A.AgentCode, A.AgentName
			FROM [dbo].[Tickets] T WITH(NOLOCK)
			JOIN [dbo].[Agent] A WITH(NOLOCK) ON A.IdAgent = T.IdAgent
			WHERE IdProduct = ISNULL(@IdProduct, IdProduct) AND Reference = ISNULL(@IdTransaction, Reference)
			 AND IdStatus = ISNULL(@IdStatus, IdStatus) AND TicketDate between @FromDate AND @ToDate;
	 
END 

