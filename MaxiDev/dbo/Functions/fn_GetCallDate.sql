CREATE function [dbo].[fn_GetCallDate](@IdAgent int, @CurrentDate datetime)
RETURNS datetime
as
/********************************************************************
<Author>Not Known</Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="24/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
begin

declare @result datetime

set @CurrentDate=[dbo].[RemoveTimeFromDatetime](@CurrentDate);

select top 1  @result=h.DateOfLastChange 
from callhistory h WITH(NOLOCK)
join callstatus c WITH(NOLOCK) on h.idcallstatus=c.idcallstatus
where idagent=@IdAgent and h.DateOfLastChange>@CurrentDate and h.DateOfLastChange<@CurrentDate+1
order by h.DateOfLastChange desc;

set @result=isnull(@result,@CurrentDate)

return @result

end