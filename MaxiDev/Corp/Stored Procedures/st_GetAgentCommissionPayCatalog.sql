CREATE PROCEDURE [Corp].[st_GetAgentCommissionPayCatalog]
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;
select IdAgentCommissionPay,AgentCommissionPayName from AgentCommissionPay with(nolock)

