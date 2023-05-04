CREATE procedure [dbo].[st_GetPureMinutesTopUpTransactionInfo]
(    
    @IdPureMinutesTopUp int
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

select a.IdAgent,
    a.AgentCode+' '+a.AgentName Agent,
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
    t.RechargeCurrency,  
	t.ErrorMsg,
	t.ResponseMsg  
from 
    PureMinutesTopUpTransaction t with(nolock)
join 
    Agent a with(nolock) on a.IdAgent=t.IdAgent
left join 
    Users u with(nolock) on u.IdUser= t.IdUser
join 
    PureMinutesStatus PS with(nolock) on ps.IdPureMinutesStatus=t.Status
left join 
    CountryPureMinutesTopUp c with(nolock) on t.CountryID=c.IdCountryPureMinutesTopUp
left join 
    CarrierPureMinutesTopUp ca with(nolock) on t.CarrierID=ca.IdCarrierPureMinutesTopUp
left join
    BillerPureMinutesTopUp b with(nolock) on t.Idbiller=b.Idbiller
where 
    IdPureMinutesTopUp=@IdPureMinutesTopUp