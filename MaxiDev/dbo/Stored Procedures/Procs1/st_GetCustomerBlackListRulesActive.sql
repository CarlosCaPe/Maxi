create procedure st_GetCustomerBlackListRulesActive
(
  @IdLenguage int
)
as

if @IdLenguage is null 
    set @IdLenguage=2  

select IdCustomerBlackListRule,Alias, case when @IdLenguage=1 then RuleNameInEnglish else RuleNameInSpanish end RuleName from customerblacklistrule where idgenericstatus=1