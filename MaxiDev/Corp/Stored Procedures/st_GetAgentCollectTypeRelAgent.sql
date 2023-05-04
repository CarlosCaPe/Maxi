CREATE PROCEDURE [Corp].[st_GetAgentCollectTypeRelAgent]
	@IdAgent INT
AS
BEGIN

	SELECT ACT.IdAgent,
		ACT.IdAgentCollectType,
		CT.Name,
		ACT.IsDefault
	FROM Corp.AgentCollectTypeRelAgent ACT WITH(NOLOCK) INNER JOIN
		dbo.AgentCollectType CT WITH(NOLOCK) ON CT.IdAgentCollectType = ACT.IdAgentCollectType
	WHERE ACT.IdAgent = @IdAgent 
		AND CT.IdAgentCollectType NOT IN (9, 5)	

END
--