CREATE PROCEDURE  [Corp].[st_GetCreditSuggestByDate] 
(@from datetime
,@to datetime
,@idAgent int
)
	as
BEGIN

	SET NOCOUNT ON;

   SELECT 
   ACS.[CreationDate]
   ,ACS.[CreditLimit]
   ,ACS.[Suggested]
    ,ACS.[DateOfLastChange]
	,ACS.[IdAgentCreditSuggest]
      ,ACS.[IsApproved]
	  ,U.UserName
  FROM [dbo].[AgentCreditSuggest] ACS with (nolock)
  INNER JOIN dbo.Users U with (nolock) ON U.IdUser= ACS.EnterByIdUser
  WHERE ACS.IdAgent=@idAgent 
  AND ACS.[DateOfLastChange]> @from
  AND ACS.[DateOfLastChange]<@to


END
