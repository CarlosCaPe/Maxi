CREATE function [dbo].[GetValueFromGatewayResponse]
(
    @XmlResponse xml,
    @Name nvarchar(max)
)
returns nvarchar(max)
Begin
declare @value nvarchar(max)

select  
  @value = N.value('Value[1]', 'nvarchar(max)')
from @XmlResponse.nodes('/root/Variable') as T(N)
where N.value('Name[1]', 'nvarchar(max)')=@Name

set @value =ISNULL(@value,'')	
return @value

End