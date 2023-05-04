CREATE procedure [dbo].[st_InactiveAgents]
/********************************************************************
<Author>Not Known</Author>
<app>MaxiJobs</app>
<Description></Description>

<ChangeLog>
<log Date="13/09/2018" Author="jmolina">Add with(nolock)</log>
<log Date="10/02/2023" Author="cagarcia">BM-513 Se amplía el tiempo de inactividad a 90</log>
</ChangeLog>
********************************************************************/
as

SELECT * INTO #TransfersInfo FROM (SELECT distinct IdAgent FROM AgentBalance with(nolock) WHERE DateOfMovement > GETDATE() -90) t
--SELECT * FROM #TransfersInfo 

SELECT * INTO #AgentSuspeded FROM (SELECT distinct ab.IdAgent FROM AgentBalance AS ab with(nolock) inner join agent a with(nolock)  ON  (ab.IdAgent = a.IdAgent)  WHERE ab.IdAgent not in ( SELECT IdAgent FROM #TransfersInfo) and a.IdAgentStatus in (1,4)) a
--SELECT * FROM #AgentSuspeded 

DECLARE @IdAgent INT
DECLARE @SystemUser INT	
SELECT @SystemUser=convert(INT,[dbo].[GetGlobalAttributeByName]('SystemUserID'))
DECLARE @DateLastTransfer VARCHAR(MAX) 

WHILE (EXISTS (SELECT 1 FROM #AgentSuspeded))
BEGIN
  
  SET @IdAgent = (SELECT TOP 1 IdAgent FROM #AgentSuspeded)  

  SET @DateLastTransfer = 'Inactive Agent, Last transaction ' + (select top 1 CONVERT(varchar, DateOfMovement,101) from AgentBalance with(nolock) where IdAgent = @IdAgent order by DateOfMovement desc) + ' ' + (select top 1 CONVERT(varchar, DateOfMovement,108) from AgentBalance with(nolock) where IdAgent = @IdAgent order by DateOfMovement desc)
  EXEC [dbo].[st_AgentStatusChange] @IdAgent,7,@SystemUser, @DateLastTransfer

  DELETE FROM #AgentSuspeded WHERE IdAgent = @IdAgent
  
END

