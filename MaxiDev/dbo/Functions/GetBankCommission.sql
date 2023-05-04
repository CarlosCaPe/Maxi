CREATE function [dbo].[GetBankCommission](@CurrentDate datetime)
RETURNS float
/********************************************************************
<Author>Not Known</Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="24/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
as
begin

declare @result float

    select top 1 @result=factornew from bankcommission with(nolock) where DateOfBankCommission=@CurrentDate and active=1 order by DateOfLastChange desc

return isnull(@result,0)

end

