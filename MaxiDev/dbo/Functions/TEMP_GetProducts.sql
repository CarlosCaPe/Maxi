
CREATE function TEMP_GetProducts ( @otherProducts XML)
returns varchar(max)
BEGIN

declare @xxx varchar(max)= convert(varchar(max),@otherProducts)

declare @OP10 varchar(100) = (len(@xxx) - DATALENGTH(replace(@xxx, '<IdOtherProduct>10</IdOtherProduct>', ''))) / len('<IdOtherProduct>10</IdOtherProduct>')
declare @OP11 varchar(100) = (len(@xxx) - DATALENGTH(replace(@xxx, '<IdOtherProduct>11</IdOtherProduct>', ''))) / len('<IdOtherProduct>11</IdOtherProduct>')
declare @OP13 varchar(100) = (len(@xxx) - DATALENGTH(replace(@xxx, '<IdOtherProduct>13</IdOtherProduct>', ''))) / len('<IdOtherProduct>13</IdOtherProduct>')
	
return ' ;OP10='+@OP10+' ;OP11='+@OP11+' ;OP13='+@OP13


END
