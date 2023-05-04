CREATE PROCEDURE [Corp].[st_CreateMessageForAgent]
(
    @IdAgent int,
    @IdMessageProvider int,
    @IdUserSender int,
    @RawMessage nvarchar(max),
    @IsSpanishLanguage bit,
    @HasError bit out,
    @Message nvarchar(max) out
)
as
Set nocount on
Begin Try
    Create table #usersInAgent
    (
	   idUser int
    )

    insert into #usersInAgent
    select IdUser from AgentUser
    where IdAgent = @IdAgent

    if(select count(1) from #usersInAgent)=0
    begin
	   Set @HasError = 1
	   Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,87) --Agencia invalida o sin usuarios
	   return
    end

    declare @IdMessageT table (idMessage int)
    declare @IdMessage int

    Insert msg.Messages
    Output INSERTED.IdMessage  into  @IdMessageT
    values (@IdMessageProvider,@IdUserSender,@RawMessage,Getdate())
    
    select top 1 @IdMessage=idMessage from @IdMessageT

    --select * from msg.MessageSubcribers
    Insert into msg.MessageSubcribers
    (IdMessage,IdUser,IdMessageStatus,DateOfLastChange)
    select @IdMessage, idUser, 1, GetDate() from #usersInAgent

    set @HasError = 0
    Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,64) --Mensaje creado correctamente
    
    return @IdMessage

End Try
Begin Catch
	Set @HasError=1
	Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33)
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_CreateMessageForAgent',Getdate(),@ErrorMessage)
End Catch
