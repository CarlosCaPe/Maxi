﻿
CREATE PROCEDURE [dbo].[sp_ReceiptUpdateMessageReader]
AS

DECLARE
    @conversation uniqueidentifier,
    @senderMsgType nvarchar(100),
    @msg xml


Begin Try 

/*WAITFOR (*/
    RECEIVE TOP(1)
        @conversation=conversation_handle,
        @msg=message_body,
        @senderMsgType=message_type_name
    FROM [QueueSW].[UpdateSenderQueue]/*);*/

    if @conversation is not null
    begin
        END CONVERSATION @conversation;-- WITH CLEANUP;
    end

End Try                                                                                            
Begin Catch
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('sp_ReceiptUpdateMessageReader',Getdate(),@ErrorMessage)                                                                                            
End Catch
