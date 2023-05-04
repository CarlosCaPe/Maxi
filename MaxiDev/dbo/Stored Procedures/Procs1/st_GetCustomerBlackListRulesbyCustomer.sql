


CREATE procedure st_GetCustomerBlackListRulesbyCustomer
(
  @IdCustomer int,
  @IdLenguage int = null
)
as

if @IdLenguage is null 
    set @IdLenguage=2  

select c.IdCustomerBlackListRule, r.alias, case when @IdLenguage=1 then r.MessageInEnglish else r.MessageInSpanish end rulename, c.Notes
from customerblacklist c
join customerblacklistrule r on c.IdCustomerBlackListRule=r.IdCustomerBlackListRule and r.idgenericstatus=1
where c.idgenericstatus=1 and idcustomer=@IdCustomer
