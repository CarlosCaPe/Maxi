--drop procedure [WellsFargo].st_EnableDisableUserAccount
create procedure [WellsFargo].st_EnableDisableAgentAccount
(   
    @IdAgentAccount int,    
    @EnterByIdUser int,
    @IdLenguage int,
    @IdGenericStatus int,
    @HasError bit out,
    @MessageError nvarchar(max) out
)
as
begin try


update [WellsFargo].[AgentAccount] set idgenericstatus=@IdGenericStatus,enterbyiduser=@EnterByIdUser,dateoflastchange=getdate() where IdAgentAccount=@IdAgentAccount


set @HasError = 0
set @MessageError=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SAVEWFACCOUNT')

End Try
Begin Catch
	Set @HasError=1	
    set @MessageError=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'ERRORSAVEWFACCOUNT')
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('WellsFargo.st_EnableDisableAgentAccount',Getdate(),@ErrorMessage)
End Catch