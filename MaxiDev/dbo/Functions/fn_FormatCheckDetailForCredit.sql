
CREATE function [dbo].[fn_FormatCheckDetailForCredit] (@IdCheckCredit int)
returns varchar(max)
/********************************************************************
<Author>Not Known</Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="24/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
Begin

declare @detail varchar(max)=''
declare @maxItems int =152

	declare @TempItems table
	(
		id int identity(1,1),
		detail varchar(100)
	);

	insert into @TempItems(detail)
	select SUBSTRING(checkNumber,1,11)+ ISNULL( REPLICATE(' ',12- LEN(SUBSTRING(checkNumber,1,11))),'')+ ISNULL( REPLICATE(' ',9-LEN(FORMAT(amount, 'C', 'en-us'))) ,'')  +FORMAT(amount, 'C', 'en-us') + CHAR(13)+CHAR(10)
	from Checks WITH(NOLOCK)
	where IdCheckCredit=@IdCheckCredit;

	if((select count(1) from @TempItems)>@maxItems)
		BEGIN
			delete @TempItems where id >=@maxItems-1;
			insert into @TempItems (detail) values ('No all items ' + CHAR(13)+CHAR(10));
			insert into @TempItems (detail) values ('were included');
		END

	select @detail=@detail+detail
			from @TempItems;

return @detail

End