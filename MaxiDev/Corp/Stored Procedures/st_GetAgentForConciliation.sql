CREATE procedure [Corp].[st_GetAgentForConciliation]
(
    @DateForConciliation datetime
)
as
set @DateForConciliation = [dbo].[RemoveTimeFromDatetime](@DateForConciliation)

select idagent,Sum(amount) deposit into #deposits from agentdeposit with(nolock) where [dbo].[RemoveTimeFromDatetime](DateOfLastChange)=@DateForConciliation group by idagent


select t.idagent,cl.Name AgentClass,AgentCode, AgentName, amountbylastday from
(
    select idagent,sum(amount) amount,sum (amountbylastday) amountbylastday from maxicollection with(nolock) where dateofcollection=@DateForConciliation group by idagent
) t
left join
#deposits d on t.idagent=d.idagent
join agent a with(nolock) on t.idagent=a.idagent 
join 
    agentclass cl with(nolock) on a.idagentclass=cl.idagentclass
where 
    amount>isnull(deposit,0) and
    amountbylastday>0 and
    a.AgentCode not like '%-B' 
    AND a.AgentCode not like '%-P'
    and isnumeric(substring(a.agentcode,1,1))=1
    and a.idagentstatus in (1,3,7)

    
--drop table #deposits

