﻿create FUNCTION [dbo].[fn_EspecialChrEKOFFSpace](          
@argumento varchar(max)          
)          
RETURNS varchar(max)          
AS          
BEGIN              
          
    set @argumento = replace(@argumento, '¿', ' ')          
    set @argumento = replace(@argumento, '?', ' ')          
    set @argumento = replace(@argumento, '¡', ' ')          
    set @argumento = replace(@argumento, '!', ' ')          
    set @argumento = replace(@argumento, 'Ü', ' ')          
    set @argumento = replace(@argumento, 'ü', ' ')          
    set @argumento = replace(@argumento, 'ª', ' ')          
    set @argumento = replace(@argumento, 'º', ' ')          
    set @argumento = replace(@argumento, '.', ' ')          
    set @argumento = replace(@argumento, '`', ' ')        
    set @argumento = replace(@argumento, '´', ' ')   
	set @argumento = replace(@argumento, '-', ' ')     
	set @argumento = replace(@argumento, '\', ' ')     
	set @argumento = replace(@argumento, '/', ' ')     
	set @argumento = replace(@argumento, '!', ' ')     
	set @argumento = replace(@argumento, '"', ' ')     
	set @argumento = replace(@argumento, '#', ' ')     
	set @argumento = replace(@argumento, '$', ' ')     
	set @argumento = replace(@argumento, '%', ' ')     
	set @argumento = replace(@argumento, '&', ' ')     
	set @argumento = replace(@argumento, '(', ' ')     
	set @argumento = replace(@argumento, ')', ' ')     
	set @argumento = replace(@argumento, '=', ' ')     
	set @argumento = replace(@argumento, '+', ' ')     
	set @argumento = replace(@argumento, '-', ' ')     
	set @argumento = replace(@argumento, '¡', ' ')     
	set @argumento = replace(@argumento, '', ' ')     
	set @argumento = replace(@argumento, '/', ' ')     
	set @argumento = replace(@argumento, ';', ' ')     
	set @argumento = replace(@argumento, '.', ' ')    
	set @argumento = replace(@argumento, ',', ' ')    
	set @argumento = replace(@argumento, ':', ' ')    
	set @argumento = replace(@argumento, '''', ' ')   
	set @argumento = replace(@argumento, '<', ' ')    
	set @argumento = replace(@argumento, '>', ' ')     
     
 return @argumento          
END 

