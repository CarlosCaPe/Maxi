
CREATE function [dbo].[GetPayerCommission](@CurrentDate datetime, @idpayer int, @idpaymenttype int)
RETURNS money
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

declare @result money

select top 1@result=commissionnew from payercommission with(nolock) where DateOfpayerCommission=@CurrentDate and idpayer=@idpayer and idpaymenttype=@idpaymenttype and active=1 order by DateOfLastChange desc

return isnull(@result,0)

end

