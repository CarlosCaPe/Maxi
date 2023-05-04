CREATE PROCEDURE st_GetUnconfirmedTransactions
(
	@IdUser			INT
)
AS
BEGIN
	SELECT
		t.IdTransfer
	FROM Transfer t WITH(NOLOCK)
		JOIN Agent a WITH(NOLOCK) ON a.IdAgent = t.IdAgent
		JOIN AgentUser au WITH(NOLOCK) ON au.IdAgent = a.IdAgent
	WHERE 
		t.IdStatus = 1
		AND t.IdPaymentMethod = 2
		AND au.IdUser = @IdUser
END
