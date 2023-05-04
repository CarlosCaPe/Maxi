CREATE PROCEDURE [dbo].[st_AgentCustomerPrivacy]
(
	@IdAgentApplication	INT
)
AS
BEGIN
	SELECT CONCAT(a.AgentCode, ' ', a.DoingBusinessAs) AgentCodeAndLegalName,
	       AgentCode,
	       AgentName,
	       DoingBusinessAs,
	       GETDATE() Date
	FROM AgentApplications a WITH(NOLOCK)
	WHERE a.IdAgentApplication = @IdAgentApplication
END