-- =============================================
-- Author:		Nevarez, Sergio
-- Create date: 2017-May-08
-- Description:	This stored gets dashboard of groups
-- =============================================
CREATE PROCEDURE [Corp].[st_GetGroupAll_Collection] 
	-- Add the parameters for the stored procedure here
	@IdAgentClass INT = NULL,
	@isSpecial BIT = 0,
	@idGroup INT = 0
AS
/********************************************************************
<Author></Author>
<app>Migracion Corporativo</app>
<Description></Description>

<ChangeLog>
	<log Date="" Author="fgonzalez">Rediseño de Stored PROCEDURE</log>
	<log Date="28/07/2020" Author="omurillo">Se agregaron parametros y se modificaron las consultas para el requerimiento M00094</log>
</ChangeLog>
*********************************************************************/
Begin Try
	
	SET NOCOUNT ON;	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @HasError INT = 0;
	DECLARE @Message VARCHAR(MAX)='';

	
	IF @IdAgentClass IS NULL BEGIN 
		SELECT idGroups,IsSpecial,IdAgentClass,GroupName FROM Collection.Groups WITH(NOLOCK) WHERE idGroups =@idGroup 
	
	END ELSE BEGIN 
	

	
		  
		  SELECT g.idGroups,GroupName,idAgentClass,StateCode,idSalesRep, AgentCode -- M00094
		  INTO #tempConfigGroups
		  FROM Collection.groups g WITH(NOLOCK)
		  JOIN Collection.GroupsDetail gd WITH(NOLOCK)
		  ON gd.idGroups = g.IdGroups
		  WHERE 
		  g.isSpecial = @isSpecial
		  AND g.idGenericStatus =1 
		   
		  CREATE NONCLUSTERED INDEX TMPX_ConfigGroups ON #tempConfigGroups(idAgentClass,idSalesRep,Statecode)
		  
		  SELECT SpecialCategory=0, S.StateCode, AgentCode = isnull(A.AgentCode,''), AgentName = isnull(A.AgentName,''), IdAgent = isnull(A.IdAgent, 0), A.IdAgentClass, ClassName=C.Name, idSeller=A.idUserSeller, SalesRep=U.UserName,
		  IsAgentAssigned = 0, TotalAgents= count(*), idConfiguredGroup = case when isnull(config.idGroups,0) > 0 then isnull(config.idGroups,0) else case when 
		  (Select count(*) from #tempConfigGroups conf where conf.idAgentClass = a.IdAgentClass AND conf.Statecode = a.agentState AND conf.idSalesRep = a.IdUserSeller AND ISNULL(conf.Agentcode, '') = '') > 0
		   then (Select TOP 1 idGroups from #tempConfigGroups conf where conf.idAgentClass = a.IdAgentClass AND conf.Statecode = a.agentState AND conf.idSalesRep = a.IdUserSeller AND ISNULL(conf.Agentcode, '') = '')
		   else isnull(config.idGroups,0) end end, NameConfigured = case when isnull(config.GroupName,'') != '' then isnull(config.GroupName,'') else case when 
		  (Select count(*) from #tempConfigGroups conf where conf.idAgentClass = a.IdAgentClass AND conf.Statecode = a.agentState AND conf.idSalesRep = a.IdUserSeller AND ISNULL(conf.Agentcode, '') = '') > 0
		   then (Select TOP 1 GroupName from #tempConfigGroups conf where conf.idAgentClass = a.IdAgentClass AND conf.Statecode = a.agentState AND conf.idSalesRep = a.IdUserSeller AND ISNULL(conf.Agentcode, '') = '')
		   else isnull(config.GroupName,'') end end
		  into #groups
		  FROM 
		  State S WITH(NOLOCK)
		  JOIN 
		  Agent A WITH (NOLOCK)  
		  ON A.AgentState=S.StateCode
		  JOIN AgentClass c WITH(NOLOCK)
		  ON c.IdAgentClass = a.IdAgentClass
		  JOIN Users u WITH(NOLOCK)
		  ON u.IdUser = A.IdUserSeller
		  LEFT JOIN #tempConfigGroups config
		  ON config.idAgentClass = a.IdAgentClass
		  AND config.Statecode = a.agentState
		  AND config.idSalesRep = a.IdUserSeller
		  AND config.Agentcode = a.AgentCode --M00094
		  WHERE S.StateCode IS NOT NULL and IdCountry=18
		  AND 1 = CASE WHEN @isSpecial=1 AND (A.IdAgentStatus = 3 OR 1 = isnull((SELECT TOP 1 Exception FROM AgentException x WITH(NOLOCK) WHERE idAgent=A.idAgent ORDER BY EnterDate DESC),0)) THEN 1
		     WHEN @isSpecial = 0 AND A.IdAgentStatus IN (1,4) AND 0 = isnull((SELECT TOP 1 Exception FROM AgentException x WITH(NOLOCK) WHERE idAgent=A.idAgent ORDER BY EnterDate DESC),0) THEN 1
		     ELSE 0 END 
		  AND A.idAgentClass=@IdAgentClass
		  GROUP BY S.StateCode ,A.idUserSeller,A.IdAgentClass, C.Name,U.UserName,config.idGroups,config.GroupName, A.AgentCode, A.AgentName, A.IdAgent, A.AgentState, config.Agentcode
		  ORDER BY S.StateCode,A.IdAgentClass
		  
		  --DROP TABLE #tempConfigGroups
		
		  select statecode INTO #missingStates from state WITH(NOLOCK) where idCountry=18 and stateCode  not in (select statecode from #groups)
		  
		  --case when (select count(*) from [Collection].[AgentByGroupDetail] where IdGroups = isnull(config.idGroups,0) and IdSeller = A.idUserSeller and IdAgent = A.IdAgent) > 0 then isnull(config.GroupName,'') else '' end 
		  --SELECT DISTINCT a.idUserSeller,u.UserName, a.AgentState
		  --INTO #missingSellers
		  --FROM Seller sel
		  --JOIN Agent a
		  --ON a.IdUserSeller = sel.IdUserSeller
		  --JOIN users u
		  --ON u.IdUser = a.IdUserSeller
		  --WHERE 
		  --a.AgentState IN (SELECT stateCode FROM #missingStates)
		  SELECT DISTINCT sel.idUserSeller,u.UserName, ms.statecode AgentState
		  INTO #missingSellers
		  FROM Seller sel WITH(NOLOCK)	  
		  JOIN users u WITH(NOLOCK)
		  ON u.IdUser = sel.IdUserSeller and u.idgenericstatus=1
		  join #missingStates ms on 1=1

		  insert into #missingSellers
		  SELECT DISTINCT sel.idUserSeller,u.UserName, ms.statecode AgentState		  
		  FROM Seller sel WITH(NOLOCK)	  
		  JOIN users u WITH(NOLOCK)
		  ON u.IdUser = sel.IdUserSeller and u.idgenericstatus=1
		  join #groups ms on 1=1 and ms.idSeller!=sel.IdUserSeller
		
		
		  SELECT 
		  distinct
		  SpecialCategory=@isSpecial,
		  AgentCode = '',
		  AgentName = '',
		  IdAgent = 0,
		  StateCode=S.AgentState,
		  IdAgentClass=@idAgentClass, 
		  ClassName=ac.Description,
		  idSeller= S.idUserSeller,
		  SalesRep=UserName,
		  TotalAgents=0,
		  IsAgentAssigned = 0,
		  idConfiguredGroup=0,
		  NameConfigured='' 
		  INTO #groups2
		  FROM 
		  #missingSellers s
		  JOIN AgentClass ac WITH(NOLOCK)
		  ON ac.IdAgentClass = @idAgentClass
		  --and IdUserSeller not in (select idSeller from #groups)
		  
		  select 
		  SpecialCategory=g.isSpecial,
		  StateCode=gd.StateCode,
		  IdAgentClass=ac.IdAgentClass, 
		  ClassName=ac.Description,
		  idSeller= IdSalesRep,
		  SalesRep=u.UserName,
		  TotalAgents=0,
		  idConfiguredGroup=g.IdGroups,
		  NameConfigured=g.GroupName
		  ,AgentCode = a.AgentCode,
		  AgentName = a.AgentName,
		  IdAgent = a.IdAgent
		  INTO #missingGroups
		  from #missingStates ms 
		  JOIN Collection.GroupsDetail gd WITH(NOLOCK)
		  ON gd.StateCode = ms.statecode
		  JOIN Collection.Groups g WITH(NOLOCK)
		  ON g.idGroups = gd.idGroups and g.idGenericStatus=1
		  JOIN AgentClass ac WITH(NOLOCK)
		  ON ac.IdAgentClass = g.idAgentClass
		  JOIN Users u WITH(NOLOCK) ON u.idUser = gd.IdSalesRep
		  JOIN Agent a
		  ON a.IdUserSeller = u.IdUser
		  WHERE g.isSpecial= @isSpecial 

		  
	   	  INSERT INTO #Groups 
	   	 
	   	 	SELECT * FROM (
			SELECT 
			g2.SpecialCategory, g2.StateCode, isnull(mg.AgentCode, g2.AgentCode) AS AgentCode, isnull(mg.AgentName, g2.AgentName) AS AgentName, isnull(mg.IdAgent, g2.IdAgent) AS IdAgent, g2.IdAgentClass, g2.ClassName, g2.idSeller, g2.SalesRep, g2.TotalAgents, g2.IsAgentAssigned,
			isnull(mg.idConfiguredGroup,g2.idConfiguredGroup) AS idConfiguredGroup, isnull(mg.NameConfigured,g2.NameConfigured) AS nameConfigured
			FROM 
			#groups2 g2
			LEFT JOIN #missingGroups mg
			ON mg.SpecialCategory = g2.SpecialCategory
			AND mg.StateCode = g2.StateCode
			AND mg.IdAgentClass = g2.IdAgentClass
			AND mg.idSeller = g2.idSeller
			AND mg.SalesRep = g2.SalesRep
			AND mg.AgentCode = g2.AgentCode
			) Z WHERE NOT EXISTS 
			(SELECT 1 FROM #groups g 
			WHERE g.SpecialCategory =z.SpecialCategory 
			AND g.StateCode = Z.StateCode 
			AND g.IdAgentClass = z.IdAgentClass
			AND g.idSeller = z.idSeller)


		  SELECT * FROM #groups WHERE StateCode != '' ORDER BY StateCode
		 
		
				  
		  DROP TABLE #tempConfigGroups
		  DROP TABLE #groups
 		  DROP TABLE #groups2
		  DROP TABLE #missingGroups
		  DROP TABLE #missingStates

	END 

End Try
Begin Catch
	Set @HasError = 1;
	Declare @ErrorMessage nvarchar(max);
	Select @ErrorMessage = ERROR_MESSAGE();
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_GetGroupAll_Collection]',Getdate(),@ErrorMessage);
End Catch