CREATE PROCEDURE  [Corp].[st_GetCreditApprovalByDate] 
(@from datetime
,@to datetime
,@idAgent int
)
	as
BEGIN

	SET NOCOUNT ON;

   SELECT 
   [CreationDate]
   ,[CreditLimit]
   ,[CreditLimitSuggested]
    ,ACA.[DateOfLastChange]
	,[IdAgentCreditApproval]
      ,[IsApproved]
	  ,U.UserName
  FROM [dbo].[AgentCreditApproval] ACA with (nolock)
  INNER JOIN dbo.Users U with (nolock) ON U.IdUser= ACA.EnterByIdUser
  WHERE ACA.IdAgent=@idAgent 
  AND ACA.[DateOfLastChange]> @from
  AND ACA.[DateOfLastChange]<@to


END
