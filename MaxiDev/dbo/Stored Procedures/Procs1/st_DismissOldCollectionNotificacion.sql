create procedure st_DismissOldCollectionNotificacion
as

declare @Date datetime

set @Date = [dbo].[RemoveTimeFromDatetime](getdate())

select idmessage into #CleanMessage from [msg].[MessageSubcribers] where idmessage in
(
    select idmessage from [msg].[Messages] where IdMessageProvider=4 and dateoflastchange<@Date
)
and idmessagestatus not in (4,5)

update 
    msg.MessageSubcribers 
set 
    IdMessageStatus = 4, DateOfLastChange=Getdate() 
where 
    IdMessage IN (select idmessage from #CleanMessage)

update 
    msg.Messages 
set  
    DateOfLastChange=Getdate() 
where 
    IdMessage IN (select idmessage from #CleanMessage)


delete from AgentNotificacionReminder where idmessage in 
(
    select idmessage from #CleanMessage
)

--select idmessage from [msg].[MessageSubcribers] where idmessage in
--(
--    select idmessage from [msg].[Messages] where IdMessageProvider=4 and dateoflastchange<@Date
--)
--and idmessagestatus not in (4,5)

--drop table #CleanMessage