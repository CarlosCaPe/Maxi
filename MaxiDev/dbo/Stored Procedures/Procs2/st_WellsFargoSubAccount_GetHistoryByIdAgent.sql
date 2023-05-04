CREATE PROCEDURE [dbo].[st_WellsFargoSubAccount_GetHistoryByIdAgent]
	@idAgent INT,
	@isAgent BIT
AS
	/********************************************************************
	<Author>mdelgado</Author>
	<app>MaxiCorp</app>
	<Description>Get History of generated reports of Wells Fargo</Description>

	<ChangeLog>
	<log Date="20170630" Author="mDelgado">Creacion del Store</log>
	</ChangeLog>
	*********************************************************************/
BEGIN

	SELECT DISTINCT arf.ReportDateGenerated DateOfChange, 'ReportWS' FieldData,  u.UserLogin UserLogin
	From AgentsReportWellsFargo arf WITH(NOLOCK)
	INNER JOIN Users u WITH(NOLOCK) ON u.IdUser = arf.IdUserWhoGenerate
	WHERE IdAgentsReportWellsFargo IN (
		SELECT IdAgentsReportWellsFargo
		FROM AgentsReportWellsFargoDetail ard WITH(NOLOCK)
		WHERE idAgent = @idAgent AND isAgent = @isAgent
	)
	ORDER BY arf.ReportDateGenerated ASC

END