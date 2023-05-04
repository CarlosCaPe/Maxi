CREATE PROCEDURE [dbo].[st_RemoveAgentSchema]
(
    @IdAgentSchema int,
    @IdLenguage int,
    @EnterByIdUser int,
    @HasError bit out,
    @MessageError nvarchar(max) out
)
as
begin try

update AgentSchema set IdAgent=null,enterbyiduser=@EnterByIdUser,dateoflastchange=getdate(),SchemaDefault=0,IdGenericStatus=2 where IdAgentSchema=@IdAgentSchema

set @HasError = 0
set @MessageError=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'DELETESCHEMA')

End Try
Begin Catch
	Set @HasError=1	
    set @MessageError=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'ERRORDELETESCHEMA')
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_RemoveAgentSchema',Getdate(),@ErrorMessage)
End Catch    
