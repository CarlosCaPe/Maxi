CREATE PROCEDURE [Corp].[st_GetDepositAgent]
    @IdAgent int
as


SELECT	AD.IdAgentDeposit, 
		AD.BankName, 
		AD.Amount, 
		AD.DepositDate, 
		AD.DateOfLastChange AS DateOfMovement, 
		AD.Notes, 
		u.UserLogin AS UserLastMovement, 
		A.SubAccount  
FROM	AgentDeposit  AS AD WITH(NOLOCK) INNER JOIN Agent AS A ON (AD.IdAgent = A.IdAgent)  
        INNER JOIN Users AS U WITH(NOLOCK) ON (u.IdUser = AD.EnterByIdUser)  
WHERE	AD.IdAgent =  @IdAgent order by AD.DateOfLastChange desc 
