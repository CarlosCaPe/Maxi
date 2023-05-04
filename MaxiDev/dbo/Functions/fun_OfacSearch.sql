CREATE FUNCTION  [dbo].[fun_OfacSearch]    
  (   
  @Name   nvarchar(max) ,   
  @Name1  nvarchar(max),   
  @Name2    nvarchar(max)  
  )   
Returns  int  
AS  
Begin 

declare @percent int
declare @value int

set @value = 0

SELECT @percent = dbo.fun_OfacnamePercentLetterPairs (@Name,@Name1,@Name2)

if @percent>=70 
	set @value=1

return @value

End
