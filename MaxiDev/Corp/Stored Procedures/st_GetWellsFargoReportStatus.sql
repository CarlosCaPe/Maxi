CREATE PROCEDURE [Corp].[st_GetWellsFargoReportStatus]
(
@from datetime = NULL,
@to datetime = NULL,
@idSeller int = NULL,
@AgentFilter varchar(max) = NULL,
@WFStatus int = -1
)
AS
/********************************************************************
<Author>mdelgado</Author>
<app>MaxiCorp</app>
<Description>Agent Report Witgh Needs & Request Wells Fargo Sub Account</Description>

<ChangeLog>
<log Date="2017/07/06" Author="mdelgado">S28 :: Creation Store</log>
<log Date="2017/07/25" Author="mdelgado">S28 :: Quitar Application cuando son liberadas, Completadas 2 palomitas y pendientes 1 palomita, Cambio Fechas creacion a NeedsWellsFargo</log>
</ChangeLog>
********************************************************************/
BEGIN

/* Example
	exec [dbo].[st_GetWellsFargoReportStatus] '20170625','20170725',NULL,'',1
*/

	IF (@from IS NULL)
	 SET @from =  DATEADD(DAY,-30,GETDATE());
	 
	IF (@to IS NULL)
		SET @to = GETDATE();

	IF (@AgentFilter IS NULL)
		SET @AgentFilter = '';

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
			a.IdAgent [IdAgent],
			a.[NeedsWFSubaccount],
			a.[NeedsWFSubaccountDate],
			a.[NeedsWFSubaccountIdUser],			
			ISNULL(uneed.UserLogin,'') [NeedsWFSubaccountUserName],
			a.[RequestWFSubaccount],
			a.[RequestWFSubaccountDate],
			a.[RequestWFSubaccountIdUser],			
			ISNULL(ureq.UserLogin,'') [RequestWFSubaccountUserName],
			--CASE WHEN NeedsWFSubaccount = 1 AND RequestWFSubaccount = 0 THEN 1 ELSE 0 END    [WFSStatus],			
			CASE WHEN (a.NeedsWFSubaccount = 1 AND a.RequestWFSubaccount = 1) THEN 1 
				ELSE
					CASE WHEN a.NeedsWFSubaccount = 1 AND (a.RequestWFSubaccount = 0 OR a.RequestWFSubaccount IS NULL) THEN 0
						ELSE -1 
					END 
				END [WFSStatus],
			a.OpenDate [AgencieDateCreation], 
			a.AgentCode, 
			a.AgentName, 
			a.IdUserSeller,
			ISNULL(u.UserName,'') [SellerName],
			a.IdAgentStatus,
			ISNULL(asts.AgentStatus,'') [StatusName],			
			CASE WHEN a.IdAgentsReportWellsFargo IS NOT NULL AND a.IdAgentsReportWellsFargo > 0 THEN 1 ELSE 0 END [isReportGenerated],
			r.ReportGeneratedDate,
			r.IdUserWhoGenerate ReportGeneratedByIdUser,
			ISNULL(r.UserName,'') ReportGeneratedByUserName,
			1 [isAgent]
		FROM agent a WITH(NOLOCK)
		LEFT JOIN AgentStatus asts WITH(NOLOCK) ON asts.IdAgentStatus = a.IdAgentStatus
		LEFT JOIN (
			SELECT a.IdAgentsReportWellsFargo, a.ReportDateGenerated AS ReportGeneratedDate, ad1.IdAgent, a.IdUserWhoGenerate, ur.UserName
			FROM AgentsReportWellsFargo a WITH(NOLOCK)
			INNER JOIN (
				SELECT DISTINCT ad.isAgent, ad.idAgent, MAX(ad.IdAgentsReportWellsFargo) IdAgentsReportWellsFargo
				FROM AgentsReportWellsFargoDetail ad
				GROUP BY ad.isAgent, ad.idAgent
			) ad1 on ad1.IdAgentsReportWellsFargo = a.IdAgentsReportWellsFargo
			INNER JOIN Users ur WITH(NOLOCK) ON ur.idUser = a.IdUserWhoGenerate and ad1.isAgent = 1
		) r ON r.IdAgent = a.IdAgent

		LEFT JOIN Users u WITH(NOLOCK) on u.IdUser = a.IdUserSeller		
		LEFT JOIN users uneed WITH(NOLOCK) ON uneed.idUser = a.NeedsWFSubaccountIdUser
		LEFT JOIN users ureq WITH(NOLOCK) ON ureq.idUser = a.RequestWFSubaccountIdUser
		WHERE a.IdAgentStatus not in (2,5,6) -- disabled, Collections, Write Off
		--AND (a.OpenDate BETWEEN @from AND @to) --cambiado por mmendoza 20170725
		AND (CAST(a.NeedsWFSubaccountDate AS DATE) BETWEEN @from AND @to)
		AND (@idSeller IS NULL OR a.IdUserSeller = @idSeller)
		AND (@AgentFilter = '' OR		
				(			
				a.AgentCode like '%' + @AgentFilter + '%'
				OR			
				a.AgentName like '%' +@AgentFilter + '%'
				OR			
				(LEN(@AgentFilter) > 4) AND a.AgentZipcode like @AgentFilter
				)
			)
		AND
		(
			@WFStatus = -1 
			OR
			(
				CASE WHEN (NeedsWFSubaccount = 1 AND RequestWFSubaccount = 1) THEN 1 
				ELSE
					CASE WHEN NeedsWFSubaccount = 1 AND (RequestWFSubaccount = 0 OR RequestWFSubaccount IS NULL) THEN 0
						ELSE -1 
					END 
				END
			) = @WFStatus
		)

		UNION 

		SELECT 
			ap.IdAgentApplication [idAgent],
			NeedsWFSubaccount, 
			AP.NeedsWFSubaccountDate,
			ap.[NeedsWFSubaccountIduser],			
			ISNULL(ua.UserLogin,'') [NeedsWFSubaccountUserName],
			ap.RequestWFSubaccount,
			ap.RequestWFSubaccountDate,
			AP.RequestWFSubaccountIdUser,			
			ISNULL(ur.UserLogin,'') [RequestWFSubaccountUserName],
			--CASE WHEN NeedsWFSubaccount = 1 AND RequestWFSubaccount = 0 THEN 1 ELSE 0 END [WFSStatus],			
			CASE WHEN (ap.NeedsWFSubaccount = 1 AND ap.RequestWFSubaccount = 1) THEN 1 
				ELSE
					CASE WHEN ap.NeedsWFSubaccount = 1 AND (ap.RequestWFSubaccount = 0 OR ap.RequestWFSubaccount IS NULL) THEN 0
						ELSE -1 
					END 
				END [WFSStatus],
			dc.[AgencieDateCreation], 
			AgentCode, 
			AgentName, 
			ap.IdUserSeller,
			ISNULL(u.UserName,'') [SellerName],
			ap.IdAgentApplicationStatus [IdAgentStatus],
			ISNULL(apsts.StatusName,'') [StatusName],			
			CASE WHEN ap.IdAgentsReportWellsFargo IS NOT NULL AND ap.IdAgentsReportWellsFargo > 0 THEN 1 ELSE 0 END [isReportGenerated],
			r.ReportGeneratedDate ReportGeneratedDate,
			r.IdUserWhoGenerate ReportGeneratedByIdUser,
			ISNULL(r.UserName,'') ReportGeneratedByUserName,
			0 [isAgent]
		FROM agentapplications ap WITH(NOLOCK) 
		LEFT JOIN AgentApplicationStatuses apsts WITH(NOLOCK) ON apsts.IdAgentApplicationStatus = ap.IdAgentApplicationStatus
		LEFT JOIN Users ua WITH(NOLOCK) on ua.IdUser = ap.NeedsWFSubaccountIduser
		LEFT JOIN Users ur WITH(NOLOCK) on ur.IdUser = ap.RequestWFSubaccountIdUser
		LEFT JOIN Users u WITH(NOLOCK) on u.IdUser = ap.IdUserSeller
		LEFT JOIN (
				SELECT a.IdAgentsReportWellsFargo, a.ReportDateGenerated AS ReportGeneratedDate, ad1.IdAgent, a.IdUserWhoGenerate, ur.UserName
				FROM AgentsReportWellsFargo a WITH(NOLOCK)
				INNER JOIN (
					SELECT DISTINCT ad.isAgent, ad.idAgent, MAX(ad.IdAgentsReportWellsFargo) IdAgentsReportWellsFargo
					FROM AgentsReportWellsFargoDetail ad
					GROUP BY ad.isAgent, ad.idAgent
				) ad1 on ad1.IdAgentsReportWellsFargo = a.IdAgentsReportWellsFargo
				INNER JOIN Users ur WITH(NOLOCK) ON ur.idUser = a.IdUserWhoGenerate and ad1.isAgent = 0
		) r ON r.idAgent = ap.IdAgentApplication
		LEFT JOIN 
		(
			SELECT MIN(aph.DateOfMovement) [AgencieDateCreation], aph.IdAgentApplication
			FROM AgentApplicationStatusHistory aph WITH(NOLOCK) 
			WHERE aph.IdAgentApplicationStatus = 1
			GROUP BY aph.IdAgentApplication
		) dc ON dc.IdAgentApplication = ap.IdAgentApplication

		WHERE ap.IdAgentApplicationStatus NOT IN (17, 18) -- Rejected, released

		--AND (dc.AgencieDateCreation BETWEEN @from AND @to) -- cambiado por mmendoza
		AND (CAST(ap.NeedsWFSubaccountDate AS DATE) BETWEEN @from AND @to)

		AND (@idSeller IS NULL OR ap.IdUserSeller = @idSeller)
		AND (@AgentFilter = '' OR		
				(			
				ap.AgentCode like '%' + @AgentFilter + '%'
				OR			
				ap.AgentName like '%' + @AgentFilter + '%'
				OR			
				(LEN(@AgentFilter) > 4) AND ap.AgentZipcode like @AgentFilter
				)
			)
		AND
		(
			@WFStatus = -1 
			OR
			(
				CASE WHEN (NeedsWFSubaccount = 1 AND RequestWFSubaccount = 1) THEN 1 
				ELSE
					CASE WHEN NeedsWFSubaccount = 1 AND (RequestWFSubaccount = 0 OR RequestWFSubaccount IS NULL) THEN 0
						ELSE -1 
					END 
				END
			) = @WFStatus
		)
	)	
	SELECT * 
	FROM WFSA_agent
	WHERE WFSStatus <> -1
	ORDER BY isReportGenerated ASC
	
END
