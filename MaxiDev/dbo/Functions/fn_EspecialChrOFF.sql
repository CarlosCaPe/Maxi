create FUNCTION [dbo].[fn_EspecialChrOFF](          
@argumento varchar(max)          
)          
RETURNS varchar(max)          
AS          
BEGIN          
    set @argumento = replace(@argumento, 'Á', 'A')          
    set @argumento = replace(@argumento, 'É', 'E')          
    set @argumento = replace(@argumento, 'Í', 'I')          
    set @argumento = replace(@argumento, 'Ó', 'O')          
    set @argumento = replace(@argumento, 'Ú', 'U')          
          
    set @argumento = replace(@argumento, 'á', 'a')          
    set @argumento = replace(@argumento, 'é', 'e')          
    set @argumento = replace(@argumento, 'í', 'i')          
    set @argumento = replace(@argumento, 'ó', 'o')          
    set @argumento = replace(@argumento, 'ú', 'u')          
          
    set @argumento = replace(@argumento, 'Ñ', 'N')          
    set @argumento = replace(@argumento, 'ñ', 'n')          
          
    set @argumento = replace(@argumento, '¿', '')          
    set @argumento = replace(@argumento, '?', '')          
    set @argumento = replace(@argumento, '¡', '')          
    set @argumento = replace(@argumento, '!', '')          
    set @argumento = replace(@argumento, 'Ü', '')          
    set @argumento = replace(@argumento, 'ü', '')          
    set @argumento = replace(@argumento, 'ª', '')          
    set @argumento = replace(@argumento, 'º', '')          
    set @argumento = replace(@argumento, '.', '')          
    set @argumento = replace(@argumento, '`', '')        
    set @argumento = replace(@argumento, '´', '')   
	set @argumento = replace(@argumento, '-', '')     
	set @argumento = replace(@argumento, '\', '')     
	set @argumento = replace(@argumento, '/', '')     
    set @argumento = replace(@argumento, '  ', ' ')     
    set @argumento = replace(@argumento, '   ', ' ')     
 return @argumento          
END 

