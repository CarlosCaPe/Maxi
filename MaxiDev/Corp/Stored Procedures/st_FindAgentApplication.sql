CREATE PROCEDURE [Corp].[st_FindAgentApplication]
(
    @BeginDate datetime,
    @EndDate datetime,
    @IdStatus int=null,
    @IdUserSeller int =null,
    @AgentName nvarchar(max) = null
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

Select @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)                
Select @BeginDate=dbo.RemoveTimeFromDatetime(@BeginDate) 

select 
    a.idagentapplication,
    a.agentcode,
    a.agentname,
    a.dateofcreation,
    a.IdAgentApplicationStatus,
    s.StatusName,
    a.iduserseller ,
    u.username,
	a.NeedsWFSubaccount,
	a.RequestWFSubaccount
from agentapplications a with(nolock)
join AgentApplicationStatuses s with(nolock) on a.IdAgentApplicationStatus=s.IdAgentApplicationStatus
join users u with(nolock) on a.iduserseller=u.iduser
where 
    a.dateofcreation>=@BeginDate and a.dateofcreation<@EndDate and
    a.iduserseller=isnull(@IdUserSeller,a.iduserseller) and
    a.IdAgentApplicationStatus=isnull(@IdStatus,a.IdAgentApplicationStatus) and
    (a.agentname like '%'+isnull(@AgentName,'')+'%' or a.agentcode like '%'+isnull(@AgentName,'')+'%')
order by 
    a.dateofcreation
