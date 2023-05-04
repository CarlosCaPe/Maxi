
CREATE procedure [dbo].[st_ReportPureMinutesTransaction]
(
    @DateFrom datetime,
    @DateTo datetime,
    @IdStatus int = null,
    @IdAgent int = null,
    @Folio int = null,
    @IsCancel bit,
    @IdLenguage int = null,
    @HasError bit output,
    @Message nvarchar(max) output
)
as

if @IdLenguage is null 
    set @IdLenguage=2  

Declare @Tot  int = 0

set @DateFrom=dbo.RemoveTimeFromDatetime(@DateFrom)
set @DateTo=dbo.RemoveTimeFromDatetime(@DateTo+1)

create table #Result
(
    AgentCode nvarchar(max),
    AgentName nvarchar(max),
    Folio int,
    ReceiveAccountNumber nvarchar(max),
    Amount money,
    Fee money,
    AgentCommission money,
    MaxiCommission money,
    Date datetime,
    Customer nvarchar(max),
    Address nvarchar(max),
    ZipCode nvarchar(max),
    Country nvarchar(max),
    State nvarchar(max),
    City nvarchar(max),
    UserLogin nvarchar(max),
    PureMinutesTransID nvarchar(max),
    AgentReferenceNumber nvarchar(max),
    ConfirmationCode nvarchar(max),
    CancelDateOfTransaction datetime,
    UserLoginCancel nvarchar(max),
    Balance money,
    PromoCode nvarchar(max),
    CreditForPromoCode money,
    STATUS nvarchar(max),
    Bonification bit,
    AccessNumber nvarchar(max)
)

if @IsCancel=1 
begin

select @Tot=count(1) from 
    PureMinutesTransaction t with(nolock)
join 
    Agent a with(nolock) on a.IdAgent=t.IdAgent
left join 
    Users u with(nolock) on u.IdUser= t.IdUser
left join 
    Users u2 with(nolock) on u2.IdUser= t.CancelIdUser
join PureMinutesStatus PS on ps.IdPureMinutesStatus=t.Status
where 
    (t.DateOfTransaction>=@DateFrom and t.DateOfTransaction<@DateTo) 
    and 
    t.Status=isnull(@IdStatus,t.Status) and t.Status not in (0,3)
    and
    t.IdPureMinutes=isnull(@Folio,t.IdPureMinutes)
    and
    a.IdAgent=isnull(@IdAgent,a.IdAgent) 
    and
    t.ReceiveAmount>0
    and
    DATEDIFF(MINUTE, DateOfTransaction, getdate())<1440

if @Tot<3001
begin
insert into #Result
select 
    a.AgentCode,
	a.AgentName,
    t.IdPureMinutes Folio,
    t.ReceiveAccountNumber ReceiveAccountNumber,
    t.ReceiveAmount Amount,
    t.Fee Fee,
    t.AgentCommission AgentCommission,
    t.CorpCommission MaxiCommission,
    t.DateOfTransaction Date,
    Isnull(t.SenderName,'') +' '+ Isnull(t.SenderFirstLastName,'') +' '+ Isnull(t.SenderSecondLastName,'') Customer,
    t.SenderAddress Address,
    t.SenderZipCode ZipCode,
    t.SenderCountry Country,
    t.SenderState State,
    t.SenderCity City,
    U.UserLogin,
    t.PureMinutesTransID,
    t.AgentReferenceNumber,
    t.ConfirmationCode,
    t.CancelDateOfTransaction,
    U2.UserLogin UserLoginCancel,
    isnull(t.Balance,0) Balance,
    t.PromoCode,
    t.CreditForPromoCode,
    Ps.StatusName STATUS,
    t.Bonification,
	t.AccessNumber  
from 
    PureMinutesTransaction t with(nolock)
join 
    Agent a with(nolock) on a.IdAgent=t.IdAgent
left join 
    Users u with(nolock) on u.IdUser= t.IdUser
left join 
    Users u2 with(nolock) on u2.IdUser= t.CancelIdUser
join PureMinutesStatus PS on ps.IdPureMinutesStatus=t.Status
where 
    (t.DateOfTransaction>=@DateFrom and t.DateOfTransaction<@DateTo) 
    and 
    t.Status=isnull(@IdStatus,t.Status) and t.Status not in (0,3)
    and
    t.IdPureMinutes=isnull(@Folio,t.IdPureMinutes)
    and
    a.IdAgent=isnull(@IdAgent,a.IdAgent) 
    and
    t.ReceiveAmount>0
    and
    DATEDIFF(MINUTE, DateOfTransaction, getdate())<1440
--order by t.IdPureMinutes
end
end
else
begin

select @Tot=count(1) from 
    PureMinutesTransaction t with(nolock)
join 
    Agent a with(nolock) on a.IdAgent=t.IdAgent
left join 
    Users u with(nolock) on u.IdUser= t.IdUser
left join 
    Users u2 with(nolock) on u2.IdUser= t.CancelIdUser
join PureMinutesStatus PS on ps.IdPureMinutesStatus=t.Status
where 
    (t.DateOfTransaction>=@DateFrom and t.DateOfTransaction<@DateTo) 
    and 
    t.Status=isnull(@IdStatus,t.Status) and t.Status not in (0,3)
    and
    t.IdPureMinutes=isnull(@Folio,t.IdPureMinutes)
    and
    a.IdAgent=isnull(@IdAgent,a.IdAgent)    

if @Tot<3001
begin    

insert into #Result
select 
    a.AgentCode,
	a.AgentName,
    t.IdPureMinutes Folio,
    t.ReceiveAccountNumber ReceiveAccountNumber,
    t.ReceiveAmount Amount,
    t.Fee Fee,
    t.AgentCommission AgentCommission,
    t.CorpCommission MaxiCommission,
    t.DateOfTransaction Date,
    Isnull(t.SenderName,'') +' '+ Isnull(t.SenderFirstLastName,'') +' '+ Isnull(t.SenderSecondLastName,'') Customer,
    t.SenderAddress Address,
    t.SenderZipCode ZipCode,
    t.SenderCountry Country,
    t.SenderState State,
    t.SenderCity City,
    U.UserLogin,
    t.PureMinutesTransID,
    t.AgentReferenceNumber,
    t.ConfirmationCode,
    t.CancelDateOfTransaction,
    U2.UserLogin UserLoginCancel,
    isnull(t.Balance,0) Balance,
    t.PromoCode,
    t.CreditForPromoCode,
    Ps.StatusName STATUS,
    t.Bonification,
	t.AccessNumber  
from 
    PureMinutesTransaction t with(nolock)
join 
    Agent a with(nolock) on a.IdAgent=t.IdAgent
left join 
    Users u with(nolock) on u.IdUser= t.IdUser
left join 
    Users u2 with(nolock) on u2.IdUser= t.CancelIdUser
join PureMinutesStatus PS on ps.IdPureMinutesStatus=t.Status
where 
    (t.DateOfTransaction>=@DateFrom and t.DateOfTransaction<@DateTo) 
    and 
    t.Status=isnull(@IdStatus,t.Status) and t.Status not in (0,3)
    and
    t.IdPureMinutes=isnull(@Folio,t.IdPureMinutes)
    and
    a.IdAgent=isnull(@IdAgent,a.IdAgent)    
--order by t.IdPureMinutes
end
end

--if @Tot=0
--begin
-- SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHNOFOUND'),@HasError=1
--end
--else
if @Tot>3000
begin
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHERROR'),@HasError=1
end
else
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHOK'),@HasError=0

select AgentCode,AgentName,Folio,ReceiveAccountNumber,Amount,Fee,AgentCommission,MaxiCommission,Date,Customer,Address,ZipCode,Country,State,City,UserLogin,PureMinutesTransID,AgentReferenceNumber,ConfirmationCode,CancelDateOfTransaction,UserLoginCancel,Balance,PromoCode,CreditForPromoCode,STATUS,Bonification,AccessNumber from #Result
order by Folio