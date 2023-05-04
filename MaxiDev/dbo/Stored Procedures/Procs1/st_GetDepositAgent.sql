CREATE procedure [dbo].[st_GetDepositAgent]
    @IdAgent int
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

SELECT	AD.IdAgentDeposit, 
		AD.BankName, 
		AD.Amount, 
		AD.DepositDate, 
		AD.DateOfLastChange AS DateOfMovement, 
		AD.Notes, 
		u.UserLogin AS UserLastMovement, 
		A.SubAccount  
FROM	AgentDeposit AS AD with(nolock) INNER JOIN Agent AS A with(nolock) ON (AD.IdAgent = A.IdAgent)  
        INNER JOIN Users AS U with(nolock) ON (u.IdUser = AD.EnterByIdUser)  
WHERE	AD.IdAgent =  @IdAgent order by AD.DateOfLastChange desc 