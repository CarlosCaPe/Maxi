CREATE PROCEDURE [Corp].[st_ConfirmaOfacMatch]
	@idOfacAuditDetail INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [IdOfacAuditDetail], [IdOfacAudit], [Name], [FirstLastName], [SecondLastName], [IdOfacAuditType], [IdOfacAuditStatus], [ChangeStatusIdUser], 
		[ChangeStatusNote], [LastChangeDate], [LastChangeNote], [LastChangeIP], [LastChangeIdUser], [AgentCode], [IdGeneric]
    FROM [dbo].[OfacAuditDetail] WITH(NOLOCK)
	WHERE IdOfacAuditDetail = @idOfacAuditDetail

END



