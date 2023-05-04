CREATE PROCEDURE [dbo].[st_GetAgentPreviewModule]
AS
BEGIN
	SELECT 
		m.IdAgentPreviewModule	Id,
		m.ModuleName			Name
	FROM AgentPreviewModule m
END
