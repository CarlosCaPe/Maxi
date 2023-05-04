CREATE procedure [dbo].[st_AgentBalanceDetailByUser]              
(              
    @IdAgent int,              
    @DateFrom datetime,               
    @DateTo datetime,              
    @IdUser int
)              
as             
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
	<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
	<log Date="2022/08/15" Author="jcsierra">Use the discount column when calculated Fee</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

Select @DateFrom=dbo.RemoveTimeFromDatetime(@DateFrom),@DateTo=dbo.RemoveTimeFromDatetime(@DateTo+1)              

(
Select    
    --0 IdAgentBalance,     
    'TRAN' TypeOfMovement,              
    T.DateOfTransfer DateOfMovement,              
    T.Folio Reference,              
    T.CustomerName+' '+T.CustomerFirstLastName [Description],              
    C.CountryCode Country,
    T.ModifierCommissionSlider+T.ModifierExchangeRateSlider FxFee,                              
    T.AmountInDollars Amount,
    T.Fee - T.Discount Fee,                
    T.AgentCommissionExtra+T.AgentCommissionOriginal Commission,    
    T.AmountInDollars+T.Fee AmountReceived,
    case (t.IdAgentPaymentSchema)
    when 1 then t.AmountInDollars+t.Fee
    when 2 then t.AmountInDollars+t.Fee-(T.AgentCommissionExtra+T.AgentCommissionOriginal)
    end
    AmountDeposit
from 
    [Transfer] T with(nolock)
Join 
    CountryCurrency B with(nolock) on (T.IdCountryCurrency=B.IdCountryCurrency)        
Join 
    Country C with(nolock) on (B.IdCountry=C.IdCountry)  
WHERE
    T.IdAgent=@IdAgent              
    and T.EnterByIdUser=@IdUser    
    and T.DateOfTransfer>=@DateFrom and T.DateOfTransfer<@DateTo
)
UNION ALL
(
Select    
    --0 IdAgentBalance,     
    'TRAN' TypeOfMovement,              
    T.DateOfTransfer DateOfMovement,              
    T.Folio Reference,              
    T.CustomerName+' '+T.CustomerFirstLastName [Description],              
    C.CountryCode Country,              
    T.ModifierCommissionSlider+T.ModifierExchangeRateSlider FxFee,                
    T.AmountInDollars Amount,
    T.Fee - T.Discount Fee,            
    T.AgentCommissionExtra+T.AgentCommissionOriginal Commission,
    T.AmountInDollars+T.Fee AmountReceived,
    case (t.IdAgentPaymentSchema)
    when 1 then t.AmountInDollars+t.Fee
    when 2 then t.AmountInDollars+t.Fee-(T.AgentCommissionExtra+T.AgentCommissionOriginal)
    end
    AmountDeposit    
from 
    TransferClosed T with(nolock)
Join 
    CountryCurrency B with(nolock) on (T.IdCountryCurrency=B.IdCountryCurrency)        
Join 
    Country C with(nolock) on (B.IdCountry=C.IdCountry)  
WHERE
    T.IdAgent=@IdAgent              
    and T.EnterByIdUser=@IdUser    
    and T.DateOfTransfer>=@DateFrom and T.DateOfTransfer<@DateTo
)
UNION ALL
(
select  
    --0 idAgentBalance,
    'BP' TypeOfMovement,
    PaymentDate DateOfMovement,
    IdBillPayment Reference,
    BillerPaymentProviderVendorId [Description],
    '' Country,
    0 FxFee,
    ReceiptAmount Amount,
    Fee Fee,
    AgentCommission Commission,
    ReceiptAmount+Fee AmountReceived,
    case (a.IsMonthly)
    when 1 then ReceiptAmount+Fee 
    when 0 then ReceiptAmount+Fee-AgentCommission
    end
    AmountDeposit
from [dbo].[BillPaymentTransactions] t with(nolock)
--join Agent a on t.IdAgent=a.IdAgent
join dbo.AgentBalance a with(nolock) on a.idAgent = t.idAgent and  a.typeofMovement in  ('BP') and t.IdBillPayment = a.idtransfer
WHERE
    T.IdAgent=@IdAgent              
    and T.IdUser=@IdUser    
    and T.PaymentDate>=@DateFrom and T.PaymentDate<@DateTo 
)
union all
/*(
    select 
    IdPureMinutes idAgentBalance,
    'LD' TypeOfMovement, 
    DateOfTransaction DateOfMovement,
    IdPureMinutes Reference,
    SenderName + ' ' + SenderFirstLastName Description,
    SenderCountry Country,
    0 FxFee,
    ReceiveAmount Amount,
    Fee Fee,
    AgentCommission Commission,
    ReceiveAmount AmountReceived,
    case (a.IsMonthly)
    when 1 then ReceiveAmount
    when 0 then ReceiveAmount-AgentCommission
    end
    AmountDeposit
    from PureMinutesTransaction t
    join dbo.AgentBalance a on a.idAgent = t.idAgent and  a.typeofMovement in  ('LD') and t.IdPureMinutes = a.idtransfer
    WHERE
    T.IdAgent=@IdAgent              
    and T.IdUser=@IdUser    
    and T.DateOfTransaction>=@DateFrom and T.DateOfTransaction<@DateTo 
)
union all
(
    select 
    IdPureMinutesTopUp idAgentBalance,
    'TU' TypeOfMovement, 
    DateOfTransaction DateOfMovement,
    IdPureMinutesTopUp Reference,
    'Top Up' Description,
    '' Country,
    0 FxFee,
    TopUpAmount Amount,
    Fee Fee,
    AgentCommission Commission,
    TopUpAmount AmountReceived,
    case (a.IsMonthly)
    when 1 then TopUpAmount
    when 0 then TopUpAmount-AgentCommission
    end
    AmountDeposit
    from PureMinutesTopupTransaction t
    join dbo.AgentBalance a on a.idAgent = t.idAgent and  a.typeofMovement in  ('TU') and t.IdPureMinutesTopUp = a.idtransfer
    WHERE
    T.IdAgent=@IdAgent              
    and T.IdUser=@IdUser    
    and T.DateOfTransaction>=@DateFrom and T.DateOfTransaction<@DateTo 
)
union all
*/
(
    select 
    --0 idAgentBalance,
    'TTU' TypeOfMovement, 
    ReturnTimeStamp DateOfMovement,
    IdTransferTTo Reference,
    'Top Up' [Description],
    isnull(c.countrycode,'') Country,
    0 FxFee,
    RetailPrice Amount,
    0 Fee,
    AgentCommission Commission,
    RetailPrice AmountReceived,
    case (a.IsMonthly)
    when 1 then RetailPrice
    when 0 then RetailPrice-AgentCommission
    end
    AmountDeposit
    from TransferTo.[TransferTTo] t with(nolock)
    join dbo.AgentBalance a with(nolock) on a.idAgent = t.idAgent and  a.typeofMovement in  ('TTU') and t.IdProductTransfer = a.idtransfer    
    left join [TransFerTo].[Country] c with(nolock) on t.country=c.countryname    
    WHERE
    T.IdAgent=@IdAgent              
    and T.EnterByIdUser=@IdUser    
    and T.ReturnTimeStamp>=@DateFrom and T.ReturnTimeStamp<@DateTo 
)
union all
(
    select 
    --0 idAgentBalance,
    h.TypeOfMovement TypeOfMovement,     
    t.DateOfCreation DateOfMovement,
    --TransactionProviderDate DateOfMovement,
    t.IdProductTransfer Reference,
    case 
        when h.TypeOfMovement in ('RBP') then a.[Description] 
        when h.TypeOfMovement in ('RTTU') then 'Top Up'
		else a.Country 
    end [Description],  
    case 
        when h.TypeOfMovement in ('RBP') then co.CountryCode 
        when h.TypeOfMovement in ('RTTU') then co.CountryCode 
		else a.[Description] 
    end Country,
    0 FxFee,
    t.amount Amount,
    isnull(t.fee,0) Fee,
    t.AgentCommission Commission,
    case 
        when h.TypeOfMovement in ('RBP') then t.amount+t.Fee 
        else t.Amount 
    end AmountReceived,
    t.TotalAmountToCorporate
    AmountDeposit
    from [Operation].[ProductTransfer] t with(nolock)
    join dbo.AgentBalance a with(nolock) on a.idAgent = t.idAgent and  a.typeofMovement in  (select TypeOfMovement from agentbalancehelper with(nolock) where IdOtherProduct in(select distinct IdOtherProduct from [Operation].[ProductTransfer] with(nolock) where idotherproduct!=7) and isdebit=1) and t.IdProductTransfer = a.idtransfer   
    join agentbalancehelper h with(nolock) on h.IdOtherProduct=t.IdOtherProduct and h.IsDebit=1
    join otherproducts o with(nolock) on o.IdOtherProducts=t.IdOtherProduct
    left join Regalii.TransferR r with(nolock) on t.IdProductTransfer=r.IdProductTransfer
    left join Country co with(nolock) on r.IdCountry=co.IdCountry
    WHERE
    /*t.Amount>0 and t.IdStatus!=1
    and*/ T.IdAgent=@IdAgent                  
    and T.EnterByIdUser=@IdUser    
    and T.DateOfCreation>=@DateFrom and T.DateOfCreation<@DateTo     
    --and T.TransactionProviderDate>=@DateFrom and T.TransactionProviderDate<@DateTo     
)
union all
(
    select 
    a.TypeOfMovement,
    t.DateOfMovement,
    IdCheck Reference,
    name+' '+FirstLastName+' '+replace(SecondLastName,'.','') [Description],
    '' Country,
    0 FxFee,
    t.amount *(-1) amount,
    t.fee,
    0 Commission,
    t.Amount*(-1) AmountReceived,
    a.Amount *(-1) AmountDeposit
    from Checks t with(nolock)
    join AgentBalance a with(nolock) on t.IdCheck=a.IdTransfer and a.TypeOfMovement in ('CH')
    WHERE
    T.IdAgent=@IdAgent                  
    and T.EnteredByIdUser=@IdUser    
    and T.DateOfMovement>=@DateFrom and T.DateOfMovement<@DateTo
)
Order by 
    DateOfMovement asc--, IdAgentBalance asc