CREATE procedure [dbo].[st_TransferReportMacroFinanciera]  
(  
    @BeginDate DateTime,  
    @EndDate Datetime  
)  
AS  
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON; 

set @BeginDate=dbo.RemoveTimeFromDatetime(@BeginDate)                      
set @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)  
  
Select 
    t.IdTransfer,
    t.Claimcode,
    p.PayerName,
    T.DateOftransfer,
    StatusName,
    isnull(r.RefExRate,0) MacroExrate,
    Isnull(r.exrate,0) TransferExRate 
from 
    [transfer] t with(nolock)
left join 
    TransferExRates r with(nolock) on t.idtransfer=r.idtransfer
join 
    Payer p with(nolock) on t.idpayer=p.idpayer
join
    [status] s with(nolock) on t.idstatus=s.idstatus
where 
    t.idgateway=15
    and
    t.DateOftransfer>=@BeginDate and t.DateOftransfer<@EndDate
union 
Select 
    t.IdTransferClosed IdTransfer,
    t.Claimcode,
    t.PayerName,
    T.DateOftransfer,
    StatusName,
    isnull(r.RefExRate,0) MacroExrate,
    Isnull(r.exrate,0) TransferExRate 
from 
    transferclosed t with(nolock)
left join 
    TransferExRates r with(nolock) on t.IdTransferClosed=r.idtransfer
--join 
--    Payer p on t.idpayer=p.idpayer
--join
--    status s on t.idstatus=s.idstatus
where 
    t.idgateway=15
    and
    t.DateOftransfer>=@BeginDate and t.DateOftransfer<@EndDate