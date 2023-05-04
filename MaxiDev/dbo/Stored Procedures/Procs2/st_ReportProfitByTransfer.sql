CREATE procedure [dbo].[st_ReportProfitByTransfer]  
(  
@IdCountryCurrency int,  
@StartDate datetime,  
@EndDate datetime,  
@IdUserSeller int,  
@IdUserRequester int  
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
  
Select @StartDate=dbo.RemoveTimeFromDatetime(@StartDate)  
Select @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)  
  
declare @IsAllSeller bit   
set @IsAllSeller = (Select top 1 1 From [Users] with(nolock) where @IdUserSeller=0 and [IdUser] = @IdUserRequester and [IdUserType] = 1)   
  
Create Table #SellerSubordinates  
 (  
  IdSeller int  
 )  
Insert into #SellerSubordinates   
Select IdUserSeller From [Seller] with(nolock) Where @IdUserSeller=0 and ([IdUserSellerParent] = @IdUserRequester or [IdUserSeller] = @IdUserRequester)  
  
Create Table #TempAgents (IdAgent int);  
  
Create Table #Temp  
(  
Id int identity(1,1),  
IdAgent Int,  
AgentName nvarchar(max),  
AgentCode nvarchar(max),  
NumTrans int,  
NumCancel int,  
NumNet int,  
AmountTrans money,  
AmountCancel money,  
AmountNet money,  
CogsTrans money,  
CogsCancel money,  
CogsNet money,  
FxResult money,  
IncomeFee money,  
AgentcommissionMonthly money,  
AgentcommissionRetain money,  
FxFee money,  
Payercommission money,  
Result money,  
OtherCharges money,  
NetResult money,  
UnclaimedNumTrans Int,  
UnclaimedAmount money,  
UnclaimedCOGS Money  
);  
  
  
  
Insert into #TempAgents (IdAgent)  
 Select Distinct IdAgent from [Transfer]   with(nolock)
 where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End   
  and DateOfTransfer>@StartDate and DateOfTransfer<@EndDate  
   
 Union  
 Select IdAgent from TransferClosed with(nolock)  
 where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End   
  and DateOfTransfer>@StartDate and DateOfTransfer<@EndDate  
   
 Union  
 Select IdAgent from TransferClosed with(nolock)  
 where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End   
  and DateStatusChange>@StartDate and DateStatusChange<@EndDate and IdStatus in (31,22)  
   
 Union  
 Select IdAgent from [Transfer]   with(nolock)
 where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End   
  and DateStatusChange>@StartDate and DateStatusChange<@EndDate and IdStatus in (31,22)  
   
 Union  
 Select IdAgent from [Transfer] with(nolock)  
 where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End   
  and DateStatusChange>@StartDate and DateStatusChange<@EndDate and IdStatus in (27)  
  
 Insert into #Temp (IdAgent, AgentName, AgentCode)  
 Select t.IdAgent, A.AgentName, A.AgentCode   
 from #TempAgents T  
 inner join Agent A with(nolock) on (A.IdAgent = T.IdAgent)  
 where @IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)) ; 
  
  
  
 Select    
 A.IdAgent,  
 B.AgentCode,
 A.Claimcode,
 A.DateOfTransfer,
 1 as NumTrans1, 
 AmountInDollars  as AmountTrans1,  
 Round(((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)  as FxResult1,  
 case when Fee+AmountInDollars =TotalAmountToCorporate Then AgentCommission else 0 end  as AgentcommissionMonthly1,  
 case when Fee+AmountInDollars <>TotalAmountToCorporate Then AgentCommission else 0 end  as AgentcommissionRetain1,  
 Fee  as IncomeFee1,  
 ModifierCommissionSlider+ModifierExchangeRateSlider as FxFee1,
 'Transfer' as TransferType  
 from  [Transfer] A With (Nolock) 
 Join Agent B with(nolock) on (A.IdAgent=B.IdAgent) 
 where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and  
    DateOfTransfer>@StartDate and  
    DateOfTransfer<@EndDate and  
    A.IdAgent in (Select IdAgent from #TempAgents)  
  
 Union all
 
 Select    
 A.idAgent,
 B.AgentCode,
 A.Claimcode,
 A.DateOfTransfer,
 1 as NumTrans2,  
 AmountInDollars as AmountTrans2,  
 Round(((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2) as FxResult2,  
 case when Fee+AmountInDollars =TotalAmountToCorporate Then AgentCommission else 0 end  as AgentcommissionMonthly2,  
 case when Fee+AmountInDollars <>TotalAmountToCorporate Then AgentCommission else 0 end as AgentcommissionRetain2,  
 Fee as IncomeFee2, 
 ModifierCommissionSlider+ModifierExchangeRateSlider as FxFee2,  
 'Transfer' as TransferType
 from TransferClosed  A  With (Nolock)  
 Join Agent B with(nolock) on (A.IdAgent=B.IdAgent)
 where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and  
    DateOfTransfer>@StartDate and  
    DateOfTransfer<@EndDate and  
 A.IdAgent in (Select IdAgent from #TempAgents)  
   
 
 Union All
 
 Select    
 A.idAgent,
 B.AgentCode,  
 A.Claimcode,
 A.DateOfTransfer,
 1 as NumTransRej1,  
 AmountInDollars as AmountTransRej1,  
 Round(((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2) as FxResultRej1,  
 case when Fee+AmountInDollars =TotalAmountToCorporate Then AgentCommission else 0 end as AgentcommissionMonthlyRej1,  
 case when Fee+AmountInDollars <>TotalAmountToCorporate Then AgentCommission else 0 end as AgentcommissionRetainRej1,  
 Fee  as IncomeFeeRej1,  
 ModifierCommissionSlider+ModifierExchangeRateSlider as FxFeeRej1,
 'Rejected' as TransferType
 from Transfer A   With (Nolock)  
 Join Agent B with(nolock) on (A.IdAgent=B.IdAgent)
 where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and  
    DateStatusChange>@StartDate and  
    DateStatusChange<@EndDate and  
 IdStatus=31   
 
 Union All
 
 Select    
 A.idAgent,
 B.AgentCode,  
 A.Claimcode,
 A.DateOfTransfer,
 1 as NumTrans2Rej,  
 AmountInDollars as AmountTrans2Rej,  
 Round(((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2) as FxResult2Rej,  
 case when Fee+AmountInDollars =TotalAmountToCorporate Then AgentCommission else 0 end as AgentcommissionMonthly2Rej,  
 case when Fee+AmountInDollars <>TotalAmountToCorporate Then AgentCommission else 0 end as AgentcommissionRetain2Rej,  
 Fee as IncomeFee2Rej,  
 ModifierCommissionSlider+ModifierExchangeRateSlider as FxFee2Rej  ,
 'Rejected' as TransferType
 from TransferClosed A  With (Nolock)
 Join Agent B with(nolock) on (A.IdAgent=B.IdAgent)
 where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and  
    DateStatusChange>@StartDate and  
    DateStatusChange<@EndDate and  
 IdStatus=31   
 
 Union All
 
 Select    
 A.idAgent,
 B.AgentCode,  
 A.Claimcode,
 A.DateOfTransfer,
 1 as NumTransCancel1,  
 AmountInDollars as AmountTransCancel1,  
 Round(((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2) as FxResultCancel1,  
 case when Fee+AmountInDollars =TotalAmountToCorporate Then AgentCommission else 0 end as AgentcommissionMonthlyCancel1,  
 case when Fee+AmountInDollars <>TotalAmountToCorporate Then AgentCommission else 0 end as AgentcommissionRetainCancel1,  
 case when TA.IdTransfer is null then 0 else Fee end  as IncomeFee,  
 ModifierCommissionSlider+ModifierExchangeRateSlider as FxFeeCancel1,
 'Cancelled' as TransferType
 from [Transfer] A   With (Nolock)  
 Join Agent B with(nolock) on (A.IdAgent=B.IdAgent)
 left join dbo.TransferNotAllowedResend TA with(nolock) on A.IdTransfer=TA.IdTransfer  
 where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and  
    DateStatusChange>@StartDate and  
    DateStatusChange<@EndDate and  
 IdStatus=22   
 
 Union All
 
 Select    
 A.idAgent,
 B.AgentCode,  
 A.Claimcode,
 A.DateOfTransfer,
 1 as NumTransCancel1,  
 AmountInDollars as AmountTransCancel1,  
 Round(((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2) as FxResultCancel1,  
 case when Fee+AmountInDollars =TotalAmountToCorporate Then AgentCommission else 0 end as AgentcommissionMonthlyCancel1,  
 case when Fee+AmountInDollars <>TotalAmountToCorporate Then AgentCommission else 0 end as AgentcommissionRetainCancel1,  
 case when TA.IdTransfer is null then 0 else Fee end  as IncomeFee,  
 ModifierCommissionSlider+ModifierExchangeRateSlider as FxFeeCancel1,
 'Cancelled' as TransferType
 from TransferClosed A   With (Nolock)  
 Join Agent B with(nolock) on (A.IdAgent=B.IdAgent)
 left join dbo.TransferNotAllowedResend TA with(nolock) on A.IdTransferClosed=TA.IdTransfer  
 where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and  
    DateStatusChange>@StartDate and  
    DateStatusChange<@EndDate and  
 IdStatus=22   
 
 
 Union All
 
 Select    
 A.idAgent,
 B.AgentCode,  
 A.Claimcode,
 A.DateOfTransfer,
 1 as NumTransRej1,  
 AmountInDollars as AmountTransRej1,  
 Round(((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2) as FxResultRej1,  
 case when Fee+AmountInDollars =TotalAmountToCorporate Then AgentCommission else 0 end as AgentcommissionMonthlyRej1,  
 case when Fee+AmountInDollars <>TotalAmountToCorporate Then AgentCommission else 0 end as AgentcommissionRetainRej1,  
 Fee  as IncomeFeeRej1,  
 ModifierCommissionSlider+ModifierExchangeRateSlider as FxFeeRej1,
 'Unclaimed' as TransferType
 from [Transfer] A   With (Nolock)  
 Join Agent B with(nolock) on (A.IdAgent=B.IdAgent)
 where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and  
    DateStatusChange>@StartDate and  
    DateStatusChange<@EndDate and  
 IdStatus=27   
 
 Union All
 
 Select    
 A.idAgent,
 B.AgentCode,  
 A.Claimcode,
 A.DateOfTransfer,
 1 as NumTrans2Rej,  
 AmountInDollars as AmountTrans2Rej,  
 Round(((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2) as FxResult2Rej,  
 case when Fee+AmountInDollars =TotalAmountToCorporate Then AgentCommission else 0 end as AgentcommissionMonthly2Rej,  
 case when Fee+AmountInDollars <>TotalAmountToCorporate Then AgentCommission else 0 end as AgentcommissionRetain2Rej,  
 Fee as IncomeFee2Rej,  
 ModifierCommissionSlider+ModifierExchangeRateSlider as FxFee2Rej  ,
 'Unclaimed' as TransferType
 from TransferClosed A  With (Nolock)
 Join Agent B with(nolock) on (A.IdAgent=B.IdAgent)
 where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and  
    DateStatusChange>@StartDate and  
    DateStatusChange<@EndDate and  
 IdStatus=27   
