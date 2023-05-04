--st_GetAgentClassStatusByIdAgent 1240,'09/18/2014'
CREATE procedure [dbo].[st_GetAgentClassStatusByIdAgent]
(
    @IdAgent int,
    @DateOfCollection datetime
)
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

set @DateOfCollection=dbo.RemoveTimeFromDatetime(@DateOfCollection)

declare @today int

Select  @today=[dbo].[GetDayOfWeek] (@DateOfCollection)         
       
if @today=6 or @today=7
begin            
    select @DateOfCollection = case 
                        when @today=6 then
                            @DateOfCollection-1 
                        when @today=7 then
                            @DateOfCollection-2
                        else
                            @DateOfCollection
                        end
end

print(@DateOfCollection)

select top 1 AgentName,isnuLL(m.IdAgentClass,a.IdAgentClass) IdAgentClass,c.name AgentClass,isnull(m.IdAgentStatus,a.IdAgentStatus) IdAgentStatus, AgentStatus
from agent a with(nolock)
left join maxicollection m with(nolock) on a.idagent=m.idagent and dateofcollection=@DateOfCollection
join agentclass c with(nolock) on c.IdAgentClass=isnuLL(m.IdAgentClass,a.IdAgentClass)
join agentstatus s with(nolock) on s.IdAgentStatus=isnull(m.IdAgentStatus,a.IdAgentStatus)
where a.idagent=@IdAgent