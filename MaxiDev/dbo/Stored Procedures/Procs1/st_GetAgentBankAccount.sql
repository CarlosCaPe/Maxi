
CREATE Procedure [dbo].[st_GetAgentBankAccount]    
(    
@IdAgent Int, 
@IdConfig  int
)    
AS    
Set nocount on  

/********************************************************************
<Author> DAlmeida </Author>
<app>Corporate </app>
<Description> Consulta </Description>

<ChangeLog>
<log Date="09/13/2017" Author="DAlmeida">Create</log>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/
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
	FROM AgentBankConfig abc with(nolock) 
	INNER JOIN Agent a with(nolock) ON a.IdAgent = abc.IdAgent
	INNER JOIN CheckConfig.Bank cb with(nolock) ON abc.IdBank = cb.IdBank
	INNER JOIN CheckConfig.BankAccount ba with(nolock) ON ba.IdBank = abc.IdBank AND ba.IdBankAccount = abc.IdAccount
	WHERE abc.IdAgent = ISNULL(@IdAgent, abc.IdAgent) AND abc.IdConfig = ISNULL(@IdConfig, abc.IdConfig)
    
End 