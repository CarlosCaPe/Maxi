/********************************************************************
<Author>Not Known</Author>
<app>JOB</app>
<Description>Elimina las sesiones del día asi como los mensajes leidos</Description>

<ChangeLog>
<log Date="07/02/2019" Author="jmolina">Se elimina depurado de sessiones en UserSession #1</log>
<log Date="24/05/2019" Author="azavala">Update para mandar a suspended todos los usuarios con inactividad mayor a 120 días; Ref:: 240520191206_azavala </log>
<log Date="28/05/2019" Author="azavala">Obtencion de globalAttribute para eliminar valor statico; Ref:: 280520191030_azavala </log>
</ChangeLog>
********************************************************************/
CREATE Procedure [dbo].[st_ClearSessionsAndMessages]
(
	@olderThat datetime
)
AS
BEGIN TRY
--Delete old sessions
--Delete UsersSession where DateOfCreation<@olderThat
declare @dayRemain int = (Select Convert(int, [Value]) from GlobalAttributes with(nolock) where [name]='RemainingDaysToChangePwd') --280520191030_azavala
update Users set IdGenericStatus=3 where IdGenericStatus=1 and IdUser in (select IdUser from UsersAditionalInfo with(nolock) where DateOfChangeLastPassword <= DATEADD(d,-@dayRemain,GETDATE()) and IdGenericStatus=1) --240520191206_azavala

--Delete old message subscribers details based on inactived sessions
delete msg.MessageSubscriberDetails from msg.MessageSubscriberDetails msd 
left join UsersSession us with (nolock) on msd.UserSession=us.SessionGuid
where us.SessionGuid is null and msd.DateOfLastChange < @olderThat

--Delete old and delivered messages subcriptions
delete msg.MessageSubcribers where IdMessageSubscriber in 
( 
	select ms.IdMessageSubscriber	from msg.MessageSubcribers ms with (nolock)
	left join msg.MessageSubscriberDetails msd with (nolock) on ms.IdMessageSubscriber = msd.IdMessageSubscriber
	where ms.IdMessageStatus in (4 ,5) --and ms.DateOfLastChange < @olderThat
	group by ms.IdMessageSubscriber
	having count(msd.IdMessageSuscriberDetail) = 0
)

--TODO delete msg.Messages?
/*
delete msg.messages where idmessage in
(
    select ms.idmessage	from msg.messages ms
	left join msg.messagesubcribers msd on ms.idmessage = msd.idmessage	
	group by ms.idmessage
	having count(msd.idmessagesubscriber) = 0
)
*/

select top 50000 ms.IdMessage	into #tmpmsg from msg.[Messages] ms with (nolock)
		left join msg.MessageSubcribers msd with (nolock) on ms.IdMessage = msd.IdMessage	
		group by ms.IdMessage
		having count(msd.IdMessageSubscriber) = 0
		order by IdMessage

	delete [dbo].[AgentNotificacionReminder] where IdMessage in
	(
		select idmessage from #tmpmsg
	)

	delete msg.[Messages] where IdMessage in
	(
		select idmessage from #tmpmsg
	)

	--Delete old message last values based on inactived sessions
	delete msg.MessageLastValues from msg.MessageLastValues mlv 
	left join UsersSession us with (nolock) on mlv.UserSession=us.SessionGuid
	where us.SessionGuid is null
END TRY
BEGIN CATCH
	DECLARE @Message varchar(max) 
	SET @Message = error_message()
	INSERT INTO dbo.ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage) VALUES('st_ClearSessionsAndMessages', GETDATE(), @Message)
END CATCH
