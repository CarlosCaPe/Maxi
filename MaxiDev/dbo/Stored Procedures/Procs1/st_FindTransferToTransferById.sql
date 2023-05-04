
CREATE procedure [dbo].[st_FindTransferToTransferById]
(    
    @Folio int =null
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
select 
    DateOfCreation DateOfTransaction,
    Destination_Msisdn phonenumber,
    IdTransferTTo folio,
    IdTransactionTTo transactionid,
    Product ProductName,
    WholeSalePrice,
    RetailPrice,
    agentcommission,
    corpcommission,
    OriginCurrency ReceivedCurrency,
    DestinationCurrency RechargedCurrency,
    agentcode,
    agentname,
    country,  
    operator carrier,  
    t.idstatus  ,
    StatusName [status],
    t.idagent,
    t.[Msisdn],
    t.LocalInfoAmount,
    t.LocalInfoCurrency,
    pinBased,
    pinValidity,
    pinCode,
    pinIvr,
    pinSerial,
    pinValue,
    pinOption1,
    pinOption2,
    pinOption3,
    t.LocalInfoValue
from 
    TransferTo.[TransferTTo] t with(nolock)
join
    agent a with(nolock) on t.idagent=a.idagent
join
    dbo.[OtherProductStatus] s with(nolock) on t.[IdStatus]=s.[IdStatus]
where   
    t.IdTransferTTo=isnull(@Folio,t.IdTransferTTo)