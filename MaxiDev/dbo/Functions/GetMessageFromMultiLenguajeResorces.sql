
CREATE function [dbo].[GetMessageFromMultiLenguajeResorces](@IdLanguage int, @MessageKey nvarchar(max))
returns nvarchar(max)
Begin
/********************************************************************
<Author></Author>
<app>MaxiAgente</app>
<Description>This stored is used in agent for search screen</Description>

<ChangeLog>
<log Date="11/13/2017" Author="DAlmeida">Add portugues message</log>
</ChangeLog>
*********************************************************************/
declare @message nvarchar(max)

--if @IdLanguage=3 
--begin
--    set @message=''
--end
--else
begin
    select 
	    @message=[Message]	
	    from dbo.[LenguageResource] with(nolock) where  [IdLenguage]= @IdLanguage and [MessageKey]=@MessageKey
    set @message =ISNULL(@message,'')	
end
return @message
End