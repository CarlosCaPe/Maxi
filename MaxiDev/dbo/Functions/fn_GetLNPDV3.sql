CREATE function [dbo].[fn_GetLNPDV3](@IdAgent int, @CurrentDate datetime)
RETURNS datetime
AS 
/********************************************************************
<Author>Not Known</Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="24/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
begin

declare @DateOfDebit datetime = null
declare @PivotDate datetime = null
declare @DepositDate datetime = null

set @CurrentDate=[dbo].[RemoveTimeFromDatetime](@CurrentDate)

--select 
--   top 1 @DateOfDebit = dateofcollection   
--from 
--    maxicollection m 
--where 
--    dateofcollection < @CurrentDate and
--    m.Idagent=@IdAgent    
--group by 
--    dateofcollection
--having
--    sum(amount)-sum(collectamount) >0
--order by dateofcollection desc

select 
    top 1 @DepositDate=DateOfLastChange 
from 
    agentdeposit with(nolock) 
where 
    DateOfLastChange < @CurrentDate
    and
    Idagent=@IdAgent  
order by 
    DateOfLastChange desc

set @DepositDate=[dbo].[RemoveTimeFromDatetime](@DepositDate)+1

if @DepositDate is null
begin
    select 
        top 1 @PivotDate=dateofcollection 
    from 
        maxicollection with(nolock) 
    where 
        amountbycalendar>0 and        
        dateofcollection < @CurrentDate and
        Idagent=@IdAgent  
    order by dateofcollection  
end
else
begin
    select 
        top 1 @PivotDate=dateofcollection 
    from 
        maxicollection with(nolock) 
    where 
        amountbycalendar>0 and
        dateofcollection>=@DepositDate and
        dateofcollection < @CurrentDate and
        Idagent=@IdAgent  
    order by dateofcollection  
end

if (select sum(amount) from agentdeposit with(nolock) where idagent=@IdAgent and DateOfLastChange>=@PivotDate and DateOfLastChange<@CurrentDate group by idagent)>0
begin 
    set @PivotDate=null
end

return @PivotDate

end