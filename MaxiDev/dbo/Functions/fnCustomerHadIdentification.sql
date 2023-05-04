

CREATE function [dbo].[fnCustomerHadIdentification](@IdCustomer int, @DateOfTransfer datetime)
returns bit
/********************************************************************
<Author>Not Known</Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="24/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
BEGIN

declare @result bit=0

if(exists(select 1 from [Transfer] T WITH(NOLOCK) where IdCustomer=@idCustomer and DateOfTransfer<=@DateOfTransfer and CustomerIdCustomerIdentificationType is not null))
BEGIN
	set @result=1
END

if(@result=0 and exists(select 1 from TransferClosed T WITH(NOLOCK) where IdCustomer=@idCustomer and DateOfTransfer<=@DateOfTransfer and CustomerIdCustomerIdentificationType is not null))
BEGIN
	set @result=1
END



return @result
END