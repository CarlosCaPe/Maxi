CREATE procedure [dbo].[st_AgentBalanceInfo]              
(              
@IdAgent int,              
@DateFrom datetime,               
@DateTo datetime              
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
  
             
--Select AgentCode,              
--AgentName,              
--AgentAddress,              
--AgentCity,              
--AgentState,              
--AgentZipcode,              
--AgentPhone,              
--AgentFax,              
--1.1 as Commissions,              
--1.1 as BeginBalance,              
--1.1 as Nettransactions,              
--1.1 as Deposits,              
--1.1 as OtherCharges,              
--1.1 as AmountToPay,
--1.1 as DebtPayment,
--1.1 as Debt,
--1.1 as SpecialCommission              
--From Agent               
--Where IdAgent=0  
  
  
  
Select @DateFrom=dbo.RemoveTimeFromDatetime(@DateFrom),@DateTo=dbo.RemoveTimeFromDatetime(@DateTo+1)           
        
Declare @BalanceForward money          
        
Select top 1           
@BalanceForward=Balance           
from AgentBalance with(nolock)                
where IdAgent= @IdAgent               
and DateOfMovement<@DateFrom                
Order by DateOfMovement desc           
        
           
Select               
IdAgentBalance,              
TypeOfMovement,              
DateOfMovement,              
Amount,              
Reference,              
[Description],              
Country,              
Commission,     
FxFee,             
DebitOrCredit,              
Balance,              
IdTransfer              
into #temp              
from AgentBalance  with(nolock)             
where IdAgent=@IdAgent and DateOfMovement>=@DateFrom and DateOfMovement<@DateTo               
              
Declare @Deposits Money              
Declare @OtherCharges Money              
Declare @Transfer Money              
Declare @Cancel Money              
Declare @Rejected Money              
Declare @BeginningBalance Money              
Declare @AmountToPay Money              
Declare @Commissions Money  
Declare @OtherChargesResta Money  
Declare @DepositsResta Money
Declare @Debt Money
Declare @SpecialCommission Money
Declare @DebtPayment Money
Declare @DebtPaymentResta Money
              
Select @Deposits=Isnull(SUM(Amount),0)              
from #Temp where TypeofMovement='DEP' and DebitOrCredit='Credit'  ;
  
Select @DepositsResta=Isnull(SUM(Amount),0)              
from #Temp where TypeofMovement='DEP' and DebitOrCredit='Debit'  ;
  
Set @Deposits=@Deposits-@DepositsResta  ;
              
Select @OtherCharges=Isnull(SUM(Amount),0)              
from #Temp where TypeofMovement='CGO'  and DebitOrCredit='Credit' ;  
  
Select @OtherChargesResta=Isnull(SUM(Amount),0)              
from #Temp where TypeofMovement='CGO'  and DebitOrCredit='Debit' ;  
  
Set @OtherCharges=@OtherCharges-@OtherChargesResta;  

Select @DebtPayment=Isnull(SUM(Amount),0)              
from #Temp where TypeofMovement='DEBT'  and DebitOrCredit='Credit' ;  
  
Select @DebtPaymentResta=Isnull(SUM(Amount),0)              
from #Temp where TypeofMovement='DEBT'  and DebitOrCredit='Debit' ;  
  
Set @DebtPayment=@DebtPayment-@DebtPaymentResta ; 
  
               
              
Select @Transfer=Isnull(SUM(Amount),0)              
from #Temp where TypeofMovement='TRAN'  ;         
              
Select @Rejected=Isnull(SUM(Amount),0)              
from #Temp where TypeofMovement='REJ'    ;          
              
Select @Cancel=Isnull(SUM(Amount),0)              
from #Temp where TypeofMovement='CANC'    ;          
              
Select @Commissions=Isnull(SUM(Commission+FxFee),0)              
from #Temp where TypeOfMovement = 'CANC' OR TypeOfMovement = 'REJ' OR TypeOfMovement = 'TRAN';
              
              
Select  @BeginningBalance=@BalanceForward       
If Exists(Select 1 from #Temp )      
 Select top 1 @AmountToPay=Balance From #temp Order by  DateOfMovement desc       
Else      
    Select @AmountToPay=@BalanceForward
    
--If Exists(select top 1 1 from AgentCollection where IdAgent = @IdAgent ) 
--	select top(1) @Debt = AmountToPay from AgentCollection where IdAgent = @IdAgent order by DateofLastChange 
--Else
--	select @Debt = 0;

select    
    top 1 @Debt=d.ActualAmountToPay
from 
    agentcollectiondetail d with(nolock)
join 
    AgentCollection AC with(nolock) on d.idagentcollection=ac.IdAgentCollection and ac.idagent=@IdAgent
where D.DateofLastChange<@DateTo
order by IdAgentCollectionDetail desc   

set @Debt=isnull(@Debt,0)
  
 

--Declare @BeginDateSpecialCommission datetime = DATEADD(day,(day(@DateFrom)*-1)+1,@DateFrom)

SET @SpecialCommission=
			 (Select  SUM(SC.Commission) SpecialCommission
			 from [dbo].[SpecialCommissionBalance]  SC with(nolock)
			 WHERE SC.[DateOfApplication]>= @DateFrom AND SC.[DateOfApplication]<@DateTo and SC.idagent=@IdAgent)
	                        
              
Select AgentCode,              
AgentName,              
AgentAddress,              
AgentCity,              
AgentState,              
AgentZipcode,              
AgentPhone,              
AgentFax,              
@Commissions as Commissions,              
isNull(@BeginningBalance,0) as BeginBalance,              
@Transfer-@Rejected-@Cancel as Nettransactions,              
@Deposits as Deposits,              
@OtherCharges as OtherCharges,              
isNull(@AmountToPay,0) as AmountToPay,
isNull(@DebtPayment*-1,0) as DebtPayment,
isNull(@Debt,0) as Debt,
ISNULL(@SpecialCommission,0) SpecialCommission
From Agent  with(nolock)              
Where IdAgent=@IdAgent  


drop table #temp
