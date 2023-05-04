CREATE PROCEDURE [Corp].[st_WellsFargoSubAccount_GetHistory]
	@from datetime,
	@to datetime
AS
	/********************************************************************
	<Author>mdelgado</Author>
	<app>MaxiCorp</app>
	<Description>Get History of generated reports of Wells Fargo</Description>

	<ChangeLog>
	<log Date="20170630" Author="mDelgado">Creacion del Store</log>
	<log Date="20170721" Author="Jmoreno">Se modifica la consulta  UserName es UserLogin</log>
	</ChangeLog>
	*********************************************************************/
BEGIN

	SELECT DISTINCT arf.IdAgentsReportWellsFargo, arf.IdUserWhoGenerate, arf.ReportDateGenerated , u.UserLogin UserLogin
	FROM AgentsReportWellsFargo arf WITH(NOLOCK)
	INNER JOIN Users u WITH(NOLOCK) ON u.IdUser = arf.IdUserWhoGenerate 
	WHERE CAST(arf.ReportDateGenerated AS DATE) BETWEEN @from AND @to
	ORDER BY arf.ReportDateGenerated ASC

END
