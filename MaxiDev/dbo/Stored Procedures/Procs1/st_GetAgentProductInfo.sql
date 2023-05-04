CREATE procedure [dbo].[st_GetAgentProductInfo]
(
    @IdOtherProduct int,
    @AgentCode nvarchar(max)
)
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

declare @IdAgent int;

select @IdAgent=IdAgent from agent with(nolock) where agentcode=@AgentCode;


select idagent,AmountForAgent,
        CommissionName,cd.fromAmount CommissionFromAmount,cd.toamount CommissionToAmount, AgentCommissionInPercentage, CorporateCommissionInPercentage,
        FeeName,fd.fromAmount FeeFromAmount, fd.toamount FeeToAmount, fee, extraamount, IsFeePercentage
from 
    [AgentOtherProductInfo] i with(nolock)
left join CommissionByOtherProducts c with(nolock) on i.IdCommissionByOtherProducts=c.IdCommissionByOtherProducts
left join FeeByOtherProducts f with(nolock) on i.IdFeeByOtherProducts=f.IdFeeByOtherProducts
left join CommissionDetailByOtherProducts cd with(nolock) on cd.IdCommissionByOtherProducts=c.IdCommissionByOtherProducts
left join FeeDetailByOtherProducts fd with(nolock) on fd.IdFeeByOtherProducts=f.IdFeeByOtherProducts
where idagent=@IdAgent and IdOtherProduct=@IdOtherProduct