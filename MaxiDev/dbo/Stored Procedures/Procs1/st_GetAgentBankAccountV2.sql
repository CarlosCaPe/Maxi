CREATE Procedure [dbo].[st_GetAgentBankAccountV2]    
(    
@IdAgent Int, 
@IdConfig  int
)    
AS    
Set nocount on
Begin       

IF @IdAgent = 0
BEGIN
	SET @IdAgent = NULL
END

IF @IdConfig = 0
BEGIN
	SET @IdConfig = NULL
END
	SELECT
		IdConfig,
		abc.IdAgent,
		a.AgentName,
		abc.IdBank,
		cb.BankName,
		abc.IdAccount,
		ba.BankAccountName as AccountNo,
		EnteredByIdUser
	FROM AgentBankConfig abc (NOLOCK)
	INNER JOIN Agent a (NOLOCK) ON a.IdAgent = abc.IdAgent
	INNER JOIN CheckConfig.Bank cb (NOLOCK) ON abc.IdBank = cb.IdBank
	INNER JOIN CheckConfig.BankAccount ba (NOLOCK) ON ba.IdBank = abc.IdBank AND ba.IdBankAccount = abc.IdAccount
	WHERE abc.IdAgent = ISNULL(@IdAgent, abc.IdAgent) AND abc.IdConfig = ISNULL(@IdConfig, abc.IdConfig)
    
End 
