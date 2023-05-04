CREATE procedure [dbo].[st_ReportPureMinutesTopUpTransaction]
(
    @DateFrom datetime,
    @DateTo datetime,
    @IdStatus int = null,
    @IdAgent int = null,
    @Folio int = null
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


set @DateFrom=dbo.RemoveTimeFromDatetime(@DateFrom)
set @DateTo=dbo.RemoveTimeFromDatetime(@DateTo+1)

select 
    a.IdAgent,
    a.AgentCode,
	a.AgentName,
    t.IdPureMinutesTopUp Folio,
    t.BuyerPhonenumber,
    t.TopUpAmount Amount,
    t.Fee Fee,
    t.AgentCommission AgentCommission,
    t.CorpCommission MaxiCommission,
    t.DateOfTransaction [Date],    
    U.UserLogin,
    t.PureMinutesTopUpTransID,    
    Ps.StatusName [Status],
    isnull(c.CountryName,'') CountryName,
    isnull(ca.CarrierName,'') CarrierName,
    isnull(b.RechargeAmount,'') BillerName,
    t.TopUpNumber,
    t.EntryTimeStamp,
    t.ReceiverCurrency,
    t.RechargeCurrency    
from 
    PureMinutesTopUpTransaction t with(nolock)
join 
    Agent a with(nolock) on a.IdAgent=t.IdAgent
left join 
    Users u with(nolock) on u.IdUser= t.IdUser
join 
    PureMinutesStatus PS with(nolock) on ps.IdPureMinutesStatus=t.[Status]
left join 
    CountryPureMinutesTopUp c with(nolock) on t.CountryID=c.IdCountryPureMinutesTopUp
left join 
    CarrierPureMinutesTopUp ca with(nolock) on t.CarrierID=ca.IdCarrierPureMinutesTopUp
left join
    BillerPureMinutesTopUp b with(nolock) on t.Idbiller=b.IdBiller
where 
    (t.DateOfTransaction>=@DateFrom and t.DateOfTransaction<@DateTo) 
    and 
    t.[Status]=isnull(@IdStatus,t.[Status]) and t.[Status] not in (0,2)
    and
    t.IdPureMinutesTopUp=isnull(@Folio,t.IdPureMinutesTopUp)
    and
    a.IdAgent=isnull(@IdAgent,a.IdAgent)
order by t.IdPureMinutesTopUp