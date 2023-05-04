CREATE PROCEDURE [Corp].[st_GetActiveMessageByAgent]
(
	@IdAgent int
)
as 
SET NOCOUNT ON;

create table #Users (IdUser int, UserName nvarchar(max))
create table #Subscribers(IdMessageSubscriber int, IdMessage int, IdUser int)

insert into #Users
select u.IdUser, u.UserName 
from AgentUser au WITH(NOLOCK)
inner join Users u WITH(NOLOCK) on au.IdUser = u.IdUser
where au.IdAgent = @IdAgent

insert into #Subscribers
select IdMessageSubscriber,IdMessage, IdUser
from msg.MessageSubcribers WITH(NOLOCK)
where IdMessageStatus <= 3 AND IdUser in (select IdUser from #Users)

select IdMessage, m.IdMessageProvider, ProviderName, RawMessage, DateOfLastChange
from msg.Messages m WITH(NOLOCK)
join msg.MessageProviders p WITH(NOLOCK) on m.IdMessageProvider=p.IdMessageProvider
where IdMessage in (select IdMessage from #Subscribers)

select IdMessageSubscriber,IdMessage, IdUser from #Subscribers

select IdUser, UserName from #Users
