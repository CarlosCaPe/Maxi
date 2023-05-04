CREATE procedure [Corp].[st_AgentBalanceMoveHistoryDetail]              
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
  
declare @BalanceForward money
  
--Select 
--1 IdMoveHistory,
--'' Concept,              
--1.1 LastAmountToPay,
--1.1 ActualAmountToPay,
--1.1 AmountToPay,
--'' Note,
--GETDATE() LastChange
--From Agent               
--Where IdAgent=0  

Select @DateFrom=dbo.RemoveTimeFromDatetime(@DateFrom),@DateTo=dbo.RemoveTimeFromDatetime(@DateTo+1)   

Select top 1         
@BalanceForward=ACD.ActualAmountToPay         
from AgentCollectionDetail  acd with(nolock)              
join AgentCollection AC with(nolock) on AC.IdAgentCollection = ACD.IdAgentCollection      
where IdAgent= @IdAgent  and acd.DateofLastChange<@DateFrom              
--Order by acd.DateofLastChange desc 
Order by acd.DateofLastChange desc , IdAgentCollectionDetail desc

Select   
0 IdAgentBalance,   
'' as TypeOfMovement,
@DateFrom as DateOfMovement,       
'' as Reference,        
'Balance Forward' as [Description],        
'' as Credit,        
'' as Debit,        
isnull(@BalanceForward,0) as Balance   
union all
select 
    ACD.IdAgentCollectionDetail as IdAgentBalance, 
    --case when ACD.lastamounttopay=0 then 'CP' else ACC.Name end  TypeOfMovement,
    'CP' TypeOfMovement,
    ACD.DateofLastChange as DateOfMovement,
    --ACD.IdAgentCollectionDetail as Reference, 
    convert(varchar,ACD.IdAgentCollectionDetail) as Reference, 
    case when ACD.lastamounttopay=0 then 'Deferred Plan Started' else ACD.Note end as [Description],
    case when ACD.AmountToPay>0 then abs(ACD.AmountToPay) else 0 end Credit,
    case when ACD.AmountToPay>0 then 0 else abs(ACD.AmountToPay) end Debit,    
    ACD.ActualAmountToPay as Balance  
    --ACC.Name as Concept, 
    --ACD.AmountToPay, 
    --ACD.ActualAmountToPay, 
    --ACD.LastAmountToPay       
from 
    AgentCollectionDetail ACD with(nolock) 
inner join 
	AgentCollection AC with(nolock) on AC.IdAgentCollection = ACD.IdAgentCollection inner join
	AgentCollectionConcept ACC with(nolock) on ACC.IdAgentCollectionConcept = ACD.IdAgentCollectionConcept
where 
    AC.IdAgent = isnull(@IdAgent,AC.IdAgent) and 
    ACD.DateofLastChange >=dbo.RemoveTimeFromDatetime(@DateFrom) and ACD.DateofLastChange <dbo.RemoveTimeFromDatetime(@DateTo) and
    abs(ACD.AmountToPay)>0
order by DateOfMovement

