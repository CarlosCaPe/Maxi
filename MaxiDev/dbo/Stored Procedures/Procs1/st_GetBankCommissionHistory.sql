CREATE PROCEDURE [dbo].[st_GetBankCommissionHistory]
(
    @DateOfBankCommission datetime = null    
)
as
/********************************************************************
<Author> </Author>
<app>Corporate </app>
<Description> Consulta </Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/
--salida para historial

select 
    DateOfBankCommission,c.DateOfLastChange,c.EnterByIdUser,UserName,factorOld,factorNew--, case when c.EnterByIdUser=@IdUser then 1 else 0 end BySystem
from 
    [BankCommission] c with(nolock)
join
    users u with(nolock) on c.enterbyiduser=u.iduser
where 
    DateOfBankCommission=isnull(@DateOfBankCommission,DateOfBankCommission) /*and active=0*/ 
order by c.DateOfLastChange desc
