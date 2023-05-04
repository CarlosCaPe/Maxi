CREATE PROCEDURE [dbo].[st_GetComplianceOfficerDesignation]
(
	@IdAgentApplication	INT
)
AS
BEGIN


	SELECT
		CONCAT(a.AgentCode, ' ', a.DoingBusinessAs) AgentCodeAndLegalName, 
		CASE 
			WHEN a.ComplianceOfficerTitle IS NULL OR a.ComplianceOfficerName IS NULL THEN 'Unknown'
			ELSE CONCAT(LTRIM(RTRIM(a.ComplianceOfficerName)), ' (', a.ComplianceOfficerTitle, ')') 
		END NameAndTitle,  
		'ApprovedBy' ApprovedBy, 
		GETDATE() Date
	FROM AgentApplications a WITH(NOLOCK)
	WHERE a.IdAgentApplication = @IdAgentApplication
END
