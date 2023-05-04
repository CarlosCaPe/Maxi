/*********************/
/* st_DismissMessage */
/*********************/
CREATE Procedure [msg].[st_DismissMessage]
(
    @IdMessage int,
    @userSession nvarchar(max),
    @HasError bit out,
    @Message nvarchar(max) out
)
as
Begin Try

declare @idsUpdated table
(
    IdMessageSubscriber int,
    IdMessageStatus INT
)

    --Actualizar IdMessageStatus de los nuevos a enviados
    Update msg.MessageSubcribers set IdMessageStatus = 5, DateOfLastChange= GetDate()
    OUTPUT    
        INSERTED.IdMessageSubscriber,
        INSERTED.IdMessageStatus
    INTO @idsUpdated
    where IdMessageStatus IN (3,4) and IdMessageSubscriber =@IdMessage

    --Insertar detalle solo de los actualizados
    insert into msg.MessageSubscriberDetails
    select IdMessageSubscriber,IdMessageStatus,@userSession,getdate() from @idsUpdated

    --select IdMessageSubscriber, IdMessageStatus, @userSession, GetDate() from MessageSubcribers
    --where IdMessageStatus = 5 and IdMessageSubscriber =@IdMessage

    if(@@ROWCOUNT=1)
	   select @HasError = 0, @Message = dbo.GetMessageFromLenguajeResorces (0,60)
    else
	   select @HasError = 1, @Message = dbo.GetMessageFromLenguajeResorces (0,59)

End Try
Begin Catch
	Set @HasError=1
	Select @Message =dbo.GetMessageFromLenguajeResorces (0,59)
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('msg.st_DismissMessage',Getdate(),@ErrorMessage)
End Catch

