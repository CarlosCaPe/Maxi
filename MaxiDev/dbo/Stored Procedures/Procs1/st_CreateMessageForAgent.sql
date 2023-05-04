

/****************************/
/* st_CreateMessageForAgent */
/****************************/
CREATE Procedure [dbo].[st_CreateMessageForAgent]
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

/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="24/01/2018" Author="jmolina">Add with(nolock) And Schema</log>
</ChangeLog>
********************************************************************/

Set nocount on
Begin Try
    Create table #usersInAgent
    (
	   idUser int
    )

    insert into #usersInAgent
    select IdUser from [dbo].AgentUser WITH(NOLOCK)
    where IdAgent = @IdAgent

    if(select count(1) from #usersInAgent WITH(NOLOCK))=0
    begin
	   Set @HasError = 1
	   Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,87) --Agencia invalida o sin usuarios
	   return
    end

    declare @IdMessageT table (idMessage int)
    declare @IdMessage int

    Insert msg.[Messages]
    Output INSERTED.IdMessage  into  @IdMessageT
    values (@IdMessageProvider,@IdUserSender,@RawMessage,Getdate())
    
    select top 1 @IdMessage=idMessage from @IdMessageT

    --select * from msg.MessageSubcribers
    Insert into msg.MessageSubcribers
    (IdMessage,IdUser,IdMessageStatus,DateOfLastChange)
    select @IdMessage, idUser, 1, GetDate() from #usersInAgent WITH(NOLOCK)

    set @HasError = 0
    Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,64) --Mensaje creado correctamente
    
	DROP TABLE #usersInAgent

    return @IdMessage

End Try
Begin Catch
	Set @HasError=1
	Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33)
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_CreateMessageForAgent',Getdate(),@ErrorMessage)
	DROP TABLE #usersInAgent
End Catch
