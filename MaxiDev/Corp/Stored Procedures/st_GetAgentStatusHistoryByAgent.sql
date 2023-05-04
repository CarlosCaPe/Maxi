CREATE PROCEDURE  [Corp].[st_GetAgentStatusHistoryByAgent] 
(@from datetime
,@to datetime
,@idAgent int
)
	as
BEGIN

	SET NOCOUNT ON;

SELECT 
     ASH.[IdAgent]
	 ,U.UserName
	 ,AgS.AgentStatus
	 ,ASH.[Note]
      ,ASH.[DateOfchange]
  FROM [dbo].[AgentStatusHistory] ASH with (nolock)
  INNER JOIN dbo.Users U with (nolock) ON U.IdUser=ASH.IdUser
  INNER JOIN dbo.AgentStatus AgS with (nolock) ON AgS.IdAgentStatus= ASH.IdAgentStatus
  WHERE ASH.IdAgent=@idAgent 
  AND ASH.[DateOfchange]> @from
  AND ASH.[DateOfchange]<@to
  AND Ags.VisibleForUser = 1


END
