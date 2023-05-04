CREATE PROCEDURE  [Corp].[st_GetDepositsByAgent] 
	@idAgent int,
	@from date,
	@to date
	as
BEGIN

	SET NOCOUNT ON;
	SELECT 
	   AD.[IdAgentDeposit]
      ,AD.[BankName]
      ,AD.[Amount]
      ,AD.[DepositDate]
      ,AD.[Notes]
      ,AD.[DateOfLastChange]
	  ,AD.EnterByIdUser
	  ,U.UserName
	  ,ACT.Name as CollectType
      
  FROM [dbo].[AgentDeposit] AD WITH (nolock), dbo.Users U WITH (nolock), dbo.AgentCollectType ACT WITH (nolock)
  WHERE	AD.[IdAgent]= @idAgent
  AND AD.[DateOfLastChange]> @from
  AND AD.[DateOfLastChange]< @to
  AND AD.EnterByIdUser=U.IdUser
  AND ACT.IdAgentCollectType =  AD.IdAgentCollectType
  Order By AD.DateofLastChange desc
END
