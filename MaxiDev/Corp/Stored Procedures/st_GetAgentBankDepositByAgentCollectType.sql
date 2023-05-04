CREATE PROCEDURE Corp.st_GetAgentBankDepositByAgentCollectType
	@IdAgentCollectType	INT,
	@IsTablet			BIT
AS
BEGIN
	
	SELECT B.IdAgentBankDeposit, B.BankName, B.AccountNumber, B.DateOfLastChange, B.EnterByIdUser, B.IdGenericStatus, B.IsTablet, B.SubAccountRequired
	FROM AgentBankDepositAgentCollectTypeRelation A WITH(NOLOCK) INNER JOIN
		AgentBankDeposit B WITH(NOLOCK) ON B.IdAgentBankDeposit = A.IdAgentBankDeposit 
	WHERE A.IdAgentCollectType = @IdAgentCollectType
		AND B.IdGenericStatus = 1
		AND B.IsTablet = CASE WHEN @IsTablet = 0 THEN B.IsTablet ELSE @IsTablet END	
	ORDER BY B.BankName ASC

END