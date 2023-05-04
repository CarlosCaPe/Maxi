
create FUNCTION [dbo].[fn_RemoveNoNumbers](          
@argumento varchar(max)          
)          
RETURNS varchar(max)          
AS          
BEGIN          
    set @argumento = replace(@argumento, '(', '')          
    set @argumento = replace(@argumento, ')', '')          
    set @argumento = replace(@argumento, '-', '')          
    set @argumento = replace(@argumento, ' ', '')              
    
 return @argumento          
END 
