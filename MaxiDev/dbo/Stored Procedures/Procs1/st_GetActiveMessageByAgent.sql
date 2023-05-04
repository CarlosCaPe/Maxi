CREATE procedure [dbo].[st_GetActiveMessageByAgent] 
(
	@IdAgent int
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

create table #Users (IdUser int, UserName nvarchar(max));
create table #Subscribers(IdMessageSubscriber int, IdMessage int, IdUser int);

insert into #Users
select u.IdUser, u.UserName 
from AgentUser au with(nolock)
inner join Users u with(nolock) on au.IdUser = u.IdUser
where au.IdAgent = @IdAgent;

insert into #Subscribers
select IdMessageSubscriber,IdMessage, IdUser
from msg.MessageSubcribers with(nolock)
where IdMessageStatus <= 3 AND IdUser in (select IdUser from #Users);

select IdMessage, m.IdMessageProvider, ProviderName, RawMessage, DateOfLastChange
from msg.Messages m with(nolock)
join msg.MessageProviders p with(nolock) on m.IdMessageProvider=p.IdMessageProvider
where IdMessage in (select IdMessage from #Subscribers)

select IdMessageSubscriber,IdMessage, IdUser from #Subscribers;

select IdUser, UserName from #Users;

