CREATE procedure [dbo].[st_EndFaxProcess]
@IdQueueFax int,
@IdQueueFaxStatus int
as

update QueueFaxes set IdQueueFaxStatus=@IdQueueFaxStatus, DateEndProcess=GETDATE()  where IdQueueFax=@IdQueueFax
