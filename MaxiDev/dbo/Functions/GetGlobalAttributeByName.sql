CREATE function [dbo].[GetGlobalAttributeByName](@Name nvarchar(50))
returns nvarchar(max)
Begin
declare @value nvarchar(max)

select 
	@value=Value	
	from dbo.GlobalAttributes with(nolock) where Name =  @Name

set @value =ISNULL(@value,'')	
return @value

End

