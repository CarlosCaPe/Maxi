CREATE PROCEDURE st_GetBranchesBySchema
(
	@IdAgentSchema         INT,
	@IdPaymentType         INT,
	@IdCity                INT,
	@IdPayer               INT,
	@IdGateway             INT
)
AS
BEGIN

	IF @IdPaymentType = 2
		EXEC st_BranchToDepositBySchema @IdAgentSchema, @IdPayer, @IdCity, @IdGateway
	ELSE
		EXEC st_BranchBySchema @IdAgentSchema, @IdCity, @IdPaymentType, @IdPayer, @IdGateway

END