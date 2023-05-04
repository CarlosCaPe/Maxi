
create function [dbo].[fn_GetOwnerNUM](@ssn nvarchar(max))
RETURNS NVARCHAR(MAX)
as
begin

declare @result NVARCHAR(MAX) =''

--if isnumeric(replace(replace(@ssn,'-',''),' ',''))=0
--begin
    select top 1 @result = OwnerIdNumber from [ownecelltmpid] where SSN = @ssn order by IDAGENT desc
--end

return @result

end