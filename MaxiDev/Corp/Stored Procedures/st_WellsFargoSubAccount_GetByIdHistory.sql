CREATE PROCEDURE [Corp].[st_WellsFargoSubAccount_GetByIdHistory]
	@idReport int
AS
	/********************************************************************
	<Author>mdelgado</Author>
	<app>MaxiCorp</app>
	<Description>Get History report generated of Wells Fargo</Description>

	<ChangeLog>
	<log Date="20170630" Author="mDelgado">Creacion del Store</log>
	</ChangeLog>
	*********************************************************************/
BEGIN

	 WITH WFSA_agent (
		[idAgent],
		[NeedsWFSubaccount],
		[NeedsWFSubaccountDate],
		[NeedsWFSubaccountIdUser],
		[NeedsWFSubaccountUserName],
		[RequestWFSubaccount],
		[RequestWFSubaccountDate],		
		[RequestWFSubaccountIdUser],
		[RequestWFSubaccountUserName], 
		[WFSStatus],
		[OpenDate], 
		[AgentCode], 
		[AgentName], 
		[IdUserSeller],
		[SellerName],
		[IdAgentStatus],
		[StatusName],
		[isReportGenerated],
		[ReportGeneratedDate],
		[ReportGeneratedByIdUser],
		[ReportGeneratedByUserName],
		[isAgent]
		 )
		 AS ( 
				SELECT 
					b.IdAgent [IdAgent],
					b.[NeedsWFSubaccount],
					b.[NeedsWFSubaccountDate],
					b.[NeedsWFSubaccountIdUser],
					--ISNULL(uneed.UserName,'') [NeedsWFSubaccountUserName],
					ISNULL(uneed.UserLogin,'') [NeedsWFSubaccountUserName],
					b.[RequestWFSubaccount],
					b.[RequestWFSubaccountDate],
					b.[RequestWFSubaccountIdUser],
					--ISNULL(ureq.UserName,'') [RequestWFSubaccountUserName],
					ISNULL(ureq.UserLogin,'') [RequestWFSubaccountUserName],
					b.WFSStatus,			
					b.OpenDate [AgencieDateCreation], 
					ag.AgentCode, 
					ag.AgentName, 
					b.IdUserSeller,
					ISNULL(u.UserName,'') [SellerName],					
					b.IdAgentStatus,
					asts.AgentStatus [StatusName],			
					1 [isReportGenerated],
					a.ReportDateGenerated,
					r.IdUser ReportGeneratedByIdUser,
					--ISNULL(r.UserName,'') ReportGeneratedByUserName,
					ISNULL(r.UserLogin,'') ReportGeneratedByUserName,
					b.[isAgent]
				FROM AgentsReportWellsFargo a WITH(NOLOCK)
				INNER JOIN AgentsReportWellsFargoDetail b WITH(NOLOCK) ON b.IdAgentsReportWellsFargo = a.IdAgentsReportWellsFargo
				INNER JOIN Agent ag WITH(NOLOCK) ON ag.IdAgent = b.idAgent
				INNER JOIN AgentStatus asts WITH(NOLOCK) ON asts.IdAgentStatus = ag.IdAgentStatus
				LEFT JOIN Users r WITH(NOLOCK) on r.IdUser = a.IdUserWhoGenerate
				LEFT JOIN Users u WITH(NOLOCK) on u.IdUser = b.IdUserSeller		
				LEFT JOIN users uneed WITH(NOLOCK) ON uneed.idUser = b.NeedsWFSubaccountIdUser
				LEFT JOIN users ureq WITH(NOLOCK) ON ureq.idUser = b.RequestWFSubaccountIdUser
				WHERE b.isAgent = 1 AND a.IdAgentsReportWellsFargo = @idReport
				
				UNION 

				SELECT 
					b.IdAgent [IdAgent],
					b.[NeedsWFSubaccount],
					b.[NeedsWFSubaccountDate],
					b.[NeedsWFSubaccountIdUser],
					--ISNULL(uneed.UserName,'') [NeedsWFSubaccountUserName],
					ISNULL(uneed.UserLogin,'') [NeedsWFSubaccountUserName],
					b.[RequestWFSubaccount],
					b.[RequestWFSubaccountDate],
					b.[RequestWFSubaccountIdUser],
					--ISNULL(ureq.UserName,'') [RequestWFSubaccountUserName],
					ISNULL(ureq.UserLogin,'') [RequestWFSubaccountUserName],
					b.WFSStatus,			
					b.OpenDate [AgencieDateCreation], 
					ag.AgentCode, 
					ag.AgentName, 
					b.IdUserSeller,
					--ISNULL(u.UserName,'') [SellerName],
					ISNULL(u.UserLogin,'') [SellerName],
					b.IdAgentStatus,
					apsts.StatusName [StatusName],			
					1 [isReportGenerated],
					A.ReportDateGenerated,
					r.IdUser ReportGeneratedByIdUser,
					--ISNULL(r.UserName,'') ReportGeneratedByUserName,
					ISNULL(r.UserLogin,'') ReportGeneratedByUserName,
					b.[isAgent]
				FROM AgentsReportWellsFargo a WITH(NOLOCK)
				INNER JOIN AgentsReportWellsFargoDetail b WITH(NOLOCK) ON b.IdAgentsReportWellsFargo = a.IdAgentsReportWellsFargo
				INNER JOIN AgentApplications ag WITH(NOLOCK) ON ag.IdAgentApplication = b.idAgent
				LEFT JOIN AgentApplicationStatuses apsts WITH(NOLOCK) ON apsts.IdAgentApplicationStatus = ag.IdAgentApplication
				LEFT JOIN Users r WITH(NOLOCK) on r.IdUser = a.IdUserWhoGenerate
				LEFT JOIN Users u WITH(NOLOCK) on u.IdUser = b.IdUserSeller		
				LEFT JOIN users uneed WITH(NOLOCK) ON uneed.idUser = b.NeedsWFSubaccountIdUser
				LEFT JOIN users ureq WITH(NOLOCK) ON ureq.idUser = b.RequestWFSubaccountIdUser
				WHERE b.isAgent = 0 AND a.IdAgentsReportWellsFargo = @idReport
		 )
		 SELECT * 
			FROM WFSA_agent WITH(NOLOCK)
			ORDER BY isReportGenerated ASC
END
