/*********************/
/* st_ReadMessage */
/*********************/
CREATE Procedure [msg].[st_ReadMessage]
(
    @XMLMessage xml,
    @HasError bit out,
    @Message nvarchar(max) out
)
as
Begin Try
Declare @Msg table
(
       id int
)
Declare @DocHandle int
Declare @hasStatus bit
EXEC sp_xml_preparedocument @DocHandle OUTPUT, @XMLMessage
insert into @Msg(id)
select id
FROM OPENXML (@DocHandle, '/Messages/Message',1)
WITH (id int)
EXEC sp_xml_removedocument @DocHandle
    --Actualizar IdMessageStatus de los nuevos a enviados
Update msg.MessageSubcribers set MessageIsRead = 1, DateofRead= GetDate() where IdMessageSubscriber in (select id from @Msg) and MessageIsRead=0
declare @TempNote varchar(max),
	@TempIdTransfer int
Select distinct 'Notification was reviewed by '+ ISNULL(U.UserName,'') Note, TD.IdTransfer
Into #TransfersNote
from @Msg MT
	inner join msg.MessageSubcribers MS (nolock) on MT.id=MS.IdMessageSubscriber
	inner join [msg].[Messages] M (nolock) on M.IdMessage=MS.IdMessage and M.IdMessageProvider=2--KYC Notification
	inner join TransferNoteNotification TNN (nolock) on TNN.IdMessage =M.IdMessage
	inner join TransferNote TN (nolock) on TN.IdTransferNote=TNN.IdTransferNote
	inner join TransferDetail TD (nolock) on TD.IdTransferDetail=TN.IdTransferDetail
	inner join Users U (nolock) on U.IdUser=MS.IdUser
SELECT TOP 1 @TempNote=Note, @TempIdTransfer=IdTransfer
FROM #TransfersNote
WHILE (@TempIdTransfer is not null)
BEGIN
	EXEC [dbo].[st_SimpleAddNoteToTransfer] @TempIdTransfer,@TempNote
	--select @TempNote, @TempIdTransfer
	DELETE #TransfersNote where IdTransfer=@TempIdTransfer
	SET @TempIdTransfer= null
	
	SELECT TOP 1 @TempNote=Note, @TempIdTransfer=IdTransfer
	FROM #TransfersNote	
END
select @HasError = 0, @Message = dbo.GetMessageFromLenguajeResorces (0,60)
End Try
Begin Catch
	Set @HasError=1
	Select @Message =dbo.GetMessageFromLenguajeResorces (0,59)
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('msg.st_ReadMessage',Getdate(),@ErrorMessage)
End Catch