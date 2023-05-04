
CREATE PROCEDURE [collection].[st_GetGroupAll] 
	-- Add the parameters for the stored procedure here
	@IdAgentClass INT = NULL,
	@isSpecial BIT = 0,
	@idGroup INT = 0
AS
-- =============================================
-- Author:		Nevarez, Sergio
-- Create date: 2017-May-08
-- Description:	This stored gets dashboard of groups
-- FGONZALEZ : Rediseño de Stored PROCEDURE
-- CAMBIOS SABADO
--
--<ChangeLog>
--<log Date="18/01/2018" Author="jdarellano" Name="#1">se agregan with(nolock) para tabla "Agent" y se quita "INDEX(IX1_Agent)" por reporte.</log>
--</ChangeLog>
-- =============================================
Begin Try
	
	SET NOCOUNT ON;	

	DECLARE @HasError INT = 0;
	DECLARE @Message VARCHAR(MAX)='';

	
	IF @IdAgentClass IS NULL BEGIN 
		SELECT idGroups,IsSpecial,IdAgentClass,GroupName FROM Collection.Groups WHERE idGroups =@idGroup 
	
	END ELSE BEGIN 
	

	
		  
		  SELECT g.idGroups,GroupName,idAgentClass,StateCode,idSalesRep 
		  INTO #tempConfigGroups
		  FROM Collection.groups g
		  JOIN Collection.GroupsDetail gd
		  ON gd.idGroups = g.IdGroups
		  WHERE 
		  g.isSpecial = @isSpecial
		  AND g.idGenericStatus =1 
		   
		  CREATE NONCLUSTERED INDEX TMPX_ConfigGroups ON #tempConfigGroups(idAgentClass,idSalesRep,Statecode)
		  
		  SELECT SpecialCategory=@isSpecial, S.StateCode ,  A.IdAgentClass, ClassName=C.Name, idSeller=A.idUserSeller, SalesRep=U.UserName, TotalAgents= count(*), 
		  idConfiguredGroup = isnull(config.idGroups,0), NameConfigured=isnull(config.GroupName,'')
		  into #groups
		  FROM 
		  State S
		  JOIN 
		  --Agent A WITH (INDEX(IX1_Agent))  
		  Agent A WITH (nolock)  
		  ON A.AgentState=S.StateCode
		  JOIN AgentClass c
		  ON c.IdAgentClass = a.IdAgentClass
		  JOIN Users u
		  ON u.IdUser = A.IdUserSeller
		  LEFT JOIN #tempConfigGroups config
		  ON config.idAgentClass = a.IdAgentClass
		  AND config.Statecode = a.agentState
		  AND config.idSalesRep = a.IdUserSeller
		  WHERE S.StateCode IS NOT NULL and IdCountry=18
		  AND 1 = CASE WHEN @isSpecial=1 AND (A.IdAgentStatus = 3 OR 1 = isnull((SELECT TOP 1 Exception FROM AgentException x WHERE idAgent=A.idAgent ORDER BY EnterDate DESC),0)) THEN 1
		     WHEN @isSpecial = 0 AND A.IdAgentStatus IN (1,4) AND 0 = isnull((SELECT TOP 1 Exception FROM AgentException x WHERE idAgent=A.idAgent ORDER BY EnterDate DESC),0) THEN 1
		     ELSE 0 END 
		  AND A.idAgentClass=@IdAgentClass
		  GROUP BY S.StateCode ,A.idUserSeller,A.IdAgentClass, C.Name,U.UserName,config.idGroups,config.GroupName
		  ORDER BY S.StateCode,A.IdAgentClass
		  
		  --DROP TABLE #tempConfigGroups
		
		  select statecode INTO #missingStates from state where idCountry=18 and stateCode  not in (select statecode from #groups)
		  
		  
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
		  FROM Seller sel		  
		  JOIN users u
		  ON u.IdUser = sel.IdUserSeller and u.idgenericstatus=1
		  join #missingStates ms on 1=1

		  insert into #missingSellers
		  SELECT DISTINCT sel.idUserSeller,u.UserName, ms.statecode AgentState		  
		  FROM Seller sel		  
		  JOIN users u
		  ON u.IdUser = sel.IdUserSeller and u.idgenericstatus=1
		  join #groups ms on 1=1 and ms.idSeller!=sel.IdUserSeller
		
		
		  SELECT 
		  distinct
		  SpecialCategory=@isSpecial,
		  StateCode=AgentState,
		  IdAgentClass=@idAgentClass, 
		  ClassName=ac.Description,
		  idSeller= idUserSeller,
		  SalesRep=UserName,
		  TotalAgents=0,
		  idConfiguredGroup=0,
		  NameConfigured='' 
		  INTO #groups2
		  FROM 
		  #missingSellers s
		  JOIN AgentClass ac
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
		  INTO #missingGroups
		  from #missingStates ms 
		  JOIN Collection.GroupsDetail gd
		  ON gd.StateCode = ms.statecode
		  JOIN Collection.Groups g
		  ON g.idGroups = gd.idGroups and g.idGenericStatus=1
		  JOIN AgentClass ac
		  ON ac.IdAgentClass = g.idAgentClass
		  JOIN Users u ON u.idUser = gd.IdSalesRep
		  WHERE g.isSpecial= @isSpecial 
		  
		  
	   	  INSERT INTO #Groups 
	   	 
	   	 	SELECT * FROM (
			SELECT 
			g2.SpecialCategory, g2.StateCode, g2.IdAgentClass, g2.ClassName, g2.idSeller, g2.SalesRep, g2.TotalAgents,
			isnull(mg.idConfiguredGroup,g2.idConfiguredGroup) AS idConfiguredGroup, isnull(mg.NameConfigured,g2.NameConfigured) AS nameConfigured
			FROM 
			#groups2 g2
			LEFT JOIN #missingGroups mg
			ON mg.SpecialCategory = g2.SpecialCategory
			AND mg.StateCode = g2.StateCode
			AND mg.IdAgentClass = g2.IdAgentClass
			AND mg.idSeller = g2.idSeller
			AND mg.SalesRep = g2.SalesRep
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
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Collection.st_GetGroupAll',Getdate(),@ErrorMessage);
End Catch