CREATE procedure [dbo].[st_AgenciesOverAmountLimit] 

/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="13/07/2019" Author="jdarellano" Name="#1">Se agrega "Distinct" por duplicidad de registros.</log>
</ChangeLog>
*********************************************************************/     
AS      
--Declare @Limit Money      
--Select @Limit=dbo.GetGlobalAttributeByName('CreditLimitPorcentToShowWarning')      
      
--Select A.AgentCode,  CONVERT(varchar(20), Balance*100/CreditAmount) as Percentage       
--from Agent A       
--Join AgentCurrentBalance B On (A.IdAgent=B.IdAgent)        
--Where A.IdAgentStatus=1 and (Balance*100/CreditAmount)>@Limit  and A.CreditAmount>0
--Order by Balance*100/CreditAmount desc
--------------------------------------------------------------------------------------------
Declare @Limit Money      
Select @Limit=dbo.GetGlobalAttributeByName('CreditLimitPorcentToShowWarning')      
      
Select distinct--#1
 A.AgentCode, 
 C.Name as Class,
 Balance,
 CreditAmount,
 isnull(ACA.CreditLimitSuggested,0) CreditLimitSuggested
from Agent A with (nolock)      
 Join AgentCurrentBalance B with (nolock) On (A.IdAgent=B.IdAgent)        
 left join AgentCreditApproval ACA with (nolock) on ACA.IdAgent = A.IdAgent AND ACA.IsApproved is null
 Join AgentClass C with (nolock) on A.IdAgentClass = C.IdAgentClass
Where
 A.IdAgentStatus=1
 AND A.CreditAmount>0
 AND (Balance*100/CreditAmount)>@Limit