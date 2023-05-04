

CREATE procedure st_FindCustomerBlackList
(
    --@fullname nvarchar(max) =''
    @Name nvarchar(max) ='',
    @FirstLastName nvarchar(max) ='',
    @SecondLastName nvarchar(max) =''
)
as

select 
    IdCustomerBlackList,c.IdCustomerBlackListRule,IdCustomer,CustomerName,CustomerFirstLastName,CustomerSecondLastName,r.Alias,c.DateOfCreation, DATEADD(minute,-1,dbo.RemoveTimeFromDatetime(c.DateOfCreation)+convert(int,dbo.GetGlobalAttributeByName('TimeInCustomerBlackList'))) DateOfActive,c.EnterByIdUser, u.UserName, c.Notes
from 
    customerblacklist c
join 
    customerblacklistrule r on c.IdCustomerBlackListRule=r.IdCustomerBlackListRule
join
    users u on c.enterbyiduser=u.iduser
where 
    c.idgenericstatus=1 and
    r.idgenericstatus=1 and
    (CustomerName like '%'+@name+'%' and CustomerFirstLastName like '%'+@FirstLastName+'%' and CustomerSecondLastName like '%'+@SecondLastName+'%')
order by CustomerName,CustomerFirstLastName,CustomerSecondLastName,c.DateOfCreation
