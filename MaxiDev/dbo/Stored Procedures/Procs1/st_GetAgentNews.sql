CREATE procedure [dbo].[st_GetAgentNews]
(
    @IdAgent int
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

declare @DateNews datetime;

Select  @DateNews=dbo.RemoveTimeFromDatetime(getdate()) ;

--select @DateNews

select 
    n.idnews,begindate,enddate,title,news,newsspanish, isnull(isread,0) IsRead
from 
    news n with(nolock)
left join [AgentNews] an with(nolock) on n.idnews=an.idnews and an.idagent=@IdAgent
where 
    idgenericstatus=1 and @DateNews>=begindate and @DateNews<=enddate



