

/***************************/
/* st_CreateMessageForUser */
/***************************/
CREATE Procedure [dbo].[st_CreateMessageForUser]
(
    @IdUserReceiver int,
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
    declare @IdMessageT table (idMessage int)
    declare @IdMessage int

    Insert msg.Messages
    Output INSERTED.IdMessage  into  @IdMessageT
    values (@IdMessageProvider,@IdUserSender,@RawMessage,Getdate())
    
    select top 1 @IdMessage=idMessage from @IdMessageT

    Insert into msg.MessageSubcribers
    (IdMessage,IdUser,IdMessageStatus,DateOfLastChange)
    select @IdMessage, @IdUserReceiver, 1, GetDate() 

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


