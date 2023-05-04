CREATE PROCEDURE st_GetAgentByTransaction
(
	@IdTransfer		BIGINT
)
AS
BEGIN
	DECLARE @IdAgent	INT

	SELECT
		@IdAgent = t.IdAgent
	FROM Transfer t 
	WHERE t.IdTransfer = @IdTransfer

	EXEC st_GetAgentById @IdAgent
END