CREATE PROCEDURE [Corp].[st_ForceDismissMessages]
(
    @IdMessageSubscribers XML,
    @HasError bit out,
    @Message nvarchar(max) out
)
as
SET NOCOUNT ON;
Begin Try
    Declare @ids table
    (
	   id int
    )

	Declare @idsUpdated table 
	(
	   IdMessageSubscriber int,
       IdMessageStatus int
    )

    Declare @DocHandle int
    EXEC sp_xml_preparedocument @DocHandle OUTPUT, @IdMessageSubscribers    

    insert into @ids
    select value
    FROM OPENXML (@DocHandle, 'root/value',2)    
    WITH (value int 'text()')    
    
    EXEC sp_xml_removedocument @DocHandle    

    --Actualizar IdMessageStatus de los nuevos a enviados
    Update msg.MessageSubcribers set IdMessageStatus = 4, DateOfLastChange= GetDate()
	Output 
        inserted.IdMessageSubscriber,
        inserted.IdMessageStatus 
    Into @idsUpdated
    where IdMessageStatus<4 and IdMessageSubscriber in (select id from @ids)

    --Insertar detalle solo de los actualizados
    insert into msg.MessageSubscriberDetails
    select IdMessageSubscriber, IdMessageStatus, null, GetDate() from @idsUpdated
    
    --select IdMessageSubscriber, IdMessageStatus, '', GetDate() from msg.MessageSubcribers
    --where IdMessageSubscriber in (select id from @idsUpdated)

    if exists (select top 1 1 from @idsUpdated)
	   select @HasError = 0, @Message = dbo.GetMessageFromLenguajeResorces (0,60)
    else
	   select @HasError = 1, @Message = dbo.GetMessageFromLenguajeResorces (0,59)
	   
End Try
Begin Catch
	Set @HasError=1
	Select @Message =dbo.GetMessageFromLenguajeResorces (0,59)
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_ForceDismissMessages]',Getdate(),@ErrorMessage)
End Catch
