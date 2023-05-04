CREATE PROCEDURE [Corp].[st_GetCustomerBlackListRule]
(
    @All bit
)
as
select 
    IdCustomerBlackListRule,IdGenericStatus Active,Alias,RuleNameInSpanish, RuleNameInEnglish, c.IdCBLaction, a.[Action],MessageInSpanish,MessageInEnglish 
from 
    CustomerBlackListRule c with(nolock)
join
    CBLaction a with(nolock) on c.IdCBLaction=a.IdCBLAction
where
    IdGenericStatus= case when @All=1 then IdGenericStatus else 1 end
order by 
    alias

