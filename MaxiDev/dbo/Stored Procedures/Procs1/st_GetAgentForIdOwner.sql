CREATE PROCEDURE [dbo].[st_GetAgentForIdOwner]
@idOwner int
AS
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

Select A.IdAgent, A.AgentCode, A.AgentName, Ast.AgentStatus 
FROM Agent A with(nolock)
	inner join AgentStatus Ast with(nolock) on Ast.IdAgentStatus=A.IdAgentStatus
WHERE A.IdOwner=@idOwner
order by A.AgentCode
