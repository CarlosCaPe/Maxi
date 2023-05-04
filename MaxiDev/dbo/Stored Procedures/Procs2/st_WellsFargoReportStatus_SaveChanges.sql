

CREATE PROCEDURE [dbo].[st_WellsFargoReportStatus_SaveChanges]
(
	@AgentsReport xml
)
AS
/********************************************************************
<Author>mdelgado</Author>
<app>MaxiCorp</app>
<Description>Save changes reports</Description>

<ChangeLog>
<log Date="2017/07/06" Author="mdelgado">S28 :: Creation Store</log>
</ChangeLog>
**********************************************************************/
BEGIN

DECLARE @DocHandle INT 
EXEC sp_xml_preparedocument @DocHandle OUTPUT,@AgentsReport

	UPDATE A
	SET A.IdAgentsReportWellsFargo = NULL
	FROM AGENT A
	INNER JOIN
		(
		SELECT isAgent,idAgent
		FROM OPENXML (@DocHandle, '/WellsFargoReport/Detail',2)
		WITH
			(
				isAgent bit,
				idAgent int		
			)
		) B on a.IdAgent = b.idAgent AND b.isAgent = 1;


	UPDATE A
		SET A.IdAgentsReportWellsFargo = NULL
	FROM AgentApplications A
	INNER JOIN
		(
		SELECT isAgent,idAgent
		FROM OPENXML (@DocHandle, '/WellsFargoReport/Detail',2)
		WITH
			(
				isAgent bit,
				idAgent int		
			)
		) B on a.IdAgentApplication = b.idAgent AND b.isAgent = 0;
END