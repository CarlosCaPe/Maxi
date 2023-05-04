CREATE PROCEDURE  [Corp].[st_GetCollectionDetails_Collection] 
	@idAgent int,
	@from datetime,
	@to datetime
	as
BEGIN

	SET NOCOUNT ON;
	SELECT 
		ACD.[ActualAmountToPay]
		,ACD.[AmountToPay]
		--,ACD.[IdAgentCollectionConcept]
		,ACD.[IdAgentCollectionDetail]
		,ACD.[LastAmountToPay]
		,ACD.[Note]  
		,U.[FirstName] + ' ' + U.[LastName] + ' ' + U.[SecondLastName] as 'UserName'
		,ACD.[DateofLastChange]
  FROM [dbo].[AgentCollectionDetail] ACD with(nolock)
  inner join  dbo.Users U with(nolock) on U.IdUser=ACD.EnterByIdUser
  inner join dbo.AgentCollection AC with (nolock) ON AC.IdAgentCollection=ACD.IdAgentCollection
  AND  AC.IdAgent= @idAgent 
  WHERE ACD.DateofLastChange BETWEEN @from AND @to
  ORDER BY ACD.DateofLastChange DESC

END
