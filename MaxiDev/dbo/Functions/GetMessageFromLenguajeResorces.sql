CREATE function [dbo].[GetMessageFromLenguajeResorces](@IsSpanishLanguage bit, @idLenguageResource int)
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="13/19/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
returns nvarchar(max)
Begin
declare @message nvarchar(max)

select 
	@message=
	case
		when @IsSpanishLanguage=1 then MessageES
		else MessageUS
	end
	from dbo.LenguageResources WITH(NOLOCK) where  IdLenguageResource= @idLenguageResource

set @message =ISNULL(@message,'')	
return @message
End
