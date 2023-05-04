/**********************/
/* st_ConfirmMessages */
/**********************/
CREATE Procedure [msg].[st_ConfirmMessages]
(
    @IdMessages XML,
    @userSession nvarchar(max),
    @HasError bit out,
    @Message nvarchar(max) out
)
as
Begin Try
    Declare @ids table
    (
	   id int
    )

    declare @idsUpdated table
    (
        IdMessageSubscriber int,
        IdMessageStatus INT
    )

    Declare @DocHandle int
    EXEC sp_xml_preparedocument @DocHandle OUTPUT, @IdMessages

    insert into @ids
    select id
    FROM OPENXML (@DocHandle, '/Messages/Message',1)     
    WITH (id int)    
    
    EXEC sp_xml_removedocument @DocHandle   

    --Actualizar IdMessageStatus de los nuevos a enviados
    Update msg.MessageSubcribers set IdMessageStatus = 3, DateOfLastChange= GetDate()
    OUTPUT    
        INSERTED.IdMessageSubscriber,
        INSERTED.IdMessageStatus
    INTO @idsUpdated
    where IdMessageStatus=2 and IdMessageSubscriber in (select id from @ids)

    --Insertar detalle solo de los actualizados
    insert into msg.MessageSubscriberDetails
    select IdMessageSubscriber,IdMessageStatus,@userSession,getdate() from @idsUpdated

    --select IdMessageSubscriber, IdMessageStatus, @userSession, GetDate() from MessageSubcribers
    --where IdMessageStatus = 3 and IdMessageSubscriber in (select id from @ids)

    if(@@ROWCOUNT>0)
	   select @HasError = 0, @Message = dbo.GetMessageFromLenguajeResorces (0,60)
    else
	   select @HasError = 1, @Message = dbo.GetMessageFromLenguajeResorces (0,59)

End Try
Begin Catch
	Set @HasError=1
	Select @Message =dbo.GetMessageFromLenguajeResorces (0,59)
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('msg.st_ConfirmMessages',Getdate(),@ErrorMessage)
End Catch

