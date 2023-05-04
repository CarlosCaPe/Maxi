
create FUNCTION [dbo].[RoundBanker] (@x money, @DecimalPlaces tinyint) 
RETURNS money AS 
BEGIN

set @x = @x * power(10, @DecimalPlaces)

return
  case when @x = floor(@x) then @x
  else
    case sign(ceiling(@x) - 2*@x + floor(@x))
    when 1 then floor(@x)
    when -1 then ceiling(@x)
    else 2*round(@x/2,0) end
  end / power(10, @DecimalPlaces)

END
