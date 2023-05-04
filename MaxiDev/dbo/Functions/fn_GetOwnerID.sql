CREATE function [dbo].[fn_GetOwnerID](@FullName nvarchar(max), @ssn nvarchar(max))
RETURNS int
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

declare @result int = 1

if isnumeric(replace(replace(@ssn,'-',''),' ',''))=0
begin
    select top 1 @result = idowner from [owner] with(nolock) where @FullName=dbo.fn_EspecialChrOFF(
    Upper(
        rtrim(ltrim(isnull(Name,'')))
        +' '+
        rtrim(ltrim(isnull(LastName,'')))
        +' '+
        rtrim(ltrim(isnull(SecondLastName,'')))
    ))
	and idowner!=1
    order by idowner desc
end
else
begin
    if @ssn in ('0',
                '00000000',
                '000000000',
                '000-00-0000',
                '1')
    begin
        select top 1 @result = idowner from [owner] with(nolock) where @FullName=dbo.fn_EspecialChrOFF(
        Upper(
            rtrim(ltrim(isnull(Name,'')))
            +' '+
            rtrim(ltrim(isnull(LastName,'')))
            +' '+
            rtrim(ltrim(isnull(SecondLastName,'')))
        ))
	    and idowner!=1
    order by idowner desc
    end
    else
    begin
        select top 1 @result = idowner from [owner] with(nolock) where replace(replace(@ssn,'-',''),' ','')=replace(replace(ssn,'-',''),' ','') and idowner!=1 order by idowner desc
    end
end

return @result

end