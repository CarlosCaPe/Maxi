-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-03-05
-- Description:	Get Top up default provider by agent id
-- =============================================
CREATE PROCEDURE Operation.GetTopUpDefaultProductByAgentId
	@AgentId BIGINT,
	@ProductId INT OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT @ProductId = AP.IdOtherProducts FROM [dbo].[AgentProducts] AP (NOLOCK)
	JOIN [dbo].[OtherProducts] OP (NOLOCK) ON OP.IdOtherProducts = AP.IdOtherProducts
	WHERE
	AP.IdAgent = @AgentId
	AND OP.IdOtherProducts IN (7,9) -- TransferTo TopUp AND Lunex TopUp
	AND AP.IdGenericStatus = 1 -- Active
    
END
