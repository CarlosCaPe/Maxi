CREATE PROCEDURE [Corp].[st_GetBankCommission]
(
    @BaseDate datetime
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
--Declaracion de variables
declare @MounthPast1   datetime
declare @MounthPast2   datetime
declare @MounthActual  datetime
declare @MounthNext    datetime
declare @IdUser        int

--Fecha Base
set @BaseDate=[dbo].[RemoveTimeFromDatetime](@BaseDate)

SELECT @MounthActual = DATEADD(dd,-(DAY(@BaseDate)-1),@BaseDate)

select @MounthNext  = DATEADD(mm,1,@MounthActual),
       @MounthPast1 = DATEADD(mm,-1,@MounthActual),
       @MounthPast2 = DATEADD(mm,-2,@MounthActual)

select @IdUser = convert(int, [dbo].[GetGlobalAttributeByName]('SystemUserID'))

--select @MounthActual '@MounthActual',
--       @MounthNext '@MounthNext',
--       @MounthPast1 '@MounthPast1',
--       @MounthPast2 '@MounthPast2'



    if not exists (select 1 from [BankCommission] with(nolock) where [DateOfBankCommission]=@MounthPast2)
    begin
        exec st_SaveBankCommission @MounthPast2,@IdUser,0,0;
    end
    if not exists (select 1 from [BankCommission] with(nolock) where [DateOfBankCommission]=@MounthPast1)
    begin
        exec st_SaveBankCommission @MounthPast1,@IdUser,0,0;
    end
    if not exists (select 1 from [BankCommission] with(nolock) where [DateOfBankCommission]=@MounthActual)
    begin
        exec st_SaveBankCommission @MounthActual,@IdUser,0,0;
    end
    if not exists (select 1 from [BankCommission] with(nolock) where [DateOfBankCommission]=@MounthNext)
    begin
        exec st_SaveBankCommission @MounthNext,@IdUser,0,0;
    end


-- salida para configuracion activa
select 
   DateOfBankCommission,c.DateOfLastChange,c.EnterByIdUser,UserName,FactorOld,FactorNew, case when c.EnterByIdUser=@IdUser then 1 else 0 end BySystem
from 
    [BankCommission] c with(nolock)
join
    users u with(nolock) on c.enterbyiduser=u.iduser
where 
    DateOfBankCommission in (@MounthPast2,@MounthPast1,@MounthActual,@MounthNext) and active=1 
order by DateOfBankCommission


--salida para hhstorial

select 
    DateOfBankCommission,c.DateOfLastChange,c.EnterByIdUser,UserName,FactorOld,FactorNew--, case when c.EnterByIdUser=@IdUser then 1 else 0 end BySystem
from 
    [BankCommission] c with(nolock)
join
    users u with(nolock) on c.enterbyiduser=u.iduser
--where     
order by DateOfBankCommission, c.DateOfLastChange

