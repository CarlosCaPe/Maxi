CREATE PROCEDURE st_FindAgentSchemaById
(
	@IdAgent			INT,
	@IdAgentSchema		INT
)
AS
BEGIN

	SELECT 
		s.*
	FROM AgentSchema s WITH(NOLOCK)
	WHERE s.IdAgent = @IdAgent
	AND s.IdAgentSchema = @IdAgentSchema

END
