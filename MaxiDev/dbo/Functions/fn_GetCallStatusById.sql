CREATE function [dbo].[fn_GetCallStatusById](@IdAgent int, @CurrentDate datetime)
RETURNS nvarchar(max)
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

declare @result int

set @CurrentDate=[dbo].[RemoveTimeFromDatetime](@CurrentDate);

select top 1  @result=idcallstatus from callhistory h WITH(NOLOCK)
where idagent=@IdAgent and h.DateOfLastChange>@CurrentDate and h.DateOfLastChange<@CurrentDate+1
order by h.DateOfLastChange desc;

set @result=isnull(@result,1);

return @result

end