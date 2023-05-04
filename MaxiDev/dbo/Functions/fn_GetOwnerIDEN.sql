--ALTER function [dbo].[fn_GetOwnerPHONE](@ssn nvarchar(max))
--RETURNS NVARCHAR(MAX)
--as
--begin

--declare @result NVARCHAR(MAX) =''

----if isnumeric(replace(replace(@ssn,'-',''),' ',''))=0
----begin
--    select top 1 @result = PHONE from ownerphonetmp where SSN = @ssn order by IDAGENT desc
----end

--return @result

--end


--CREATE function [dbo].[fn_GetOwnerCELL](@ssn nvarchar(max))
--RETURNS NVARCHAR(MAX)
--as
--begin

--declare @result NVARCHAR(MAX) =''

----if isnumeric(replace(replace(@ssn,'-',''),' ',''))=0
----begin
--    select top 1 @result = CELL from [ownecelltmp] where SSN = @ssn order by IDAGENT desc
----end

--return @result

--end


create function [dbo].[fn_GetOwnerIDEN](@ssn nvarchar(max))
RETURNS NVARCHAR(MAX)
as
begin

declare @result NVARCHAR(MAX) =''

--if isnumeric(replace(replace(@ssn,'-',''),' ',''))=0
--begin
    select top 1 @result = OwnerIdType from [ownecelltmpid] where SSN = @ssn order by IDAGENT desc
--end

return @result

end