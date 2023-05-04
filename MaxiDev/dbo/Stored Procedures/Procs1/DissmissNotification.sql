CREATE procedure [dbo].[DissmissNotification]
as
BEGIN TRY
declare   @idmessage int
declare   @idmessageprovider int
declare   @idtransfer int
declare   @idagent int     
declare   @date datetime = getdate()

DECLARE	@HasError bit,
		@MessageOut varchar(max)

set @date=[dbo].[RemoveTimeFromDatetime](@date)

create table #Messages
(
    idmessage int identity (1,1),
    idmessageprovider int,
    idtransfer int,
    idagent int     
)

insert into #Messages
select distinct m.idmessageprovider,isnull(td.idtransfer,0) idtransfer,isnull(idagent,0) idagent 
from [msg].[MessageSubcribers] s with (nolock)
join msg.[messages] m with (nolock) on m.idmessage=s.idmessage
left join TransferNoteNotification  TNN with (nolock) on TNN.idmessage=s.idmessage
left join TransferNote TN with (nolock) on TNN.IdTransferNote = TN.IdTransferNote	
left join TransferDetail TD with (nolock) on TN.IdTransferDetail = TD.IdTransferDetail
left join AgentNotificacionReminder a with (nolock) on a.idmessage=s.idmessage
--where idmessagestatus in (1,2) and idmessageprovider in (2,4)
where idmessagestatus in (1,2) and idmessageprovider in (2)
order by idmessageprovider


insert into #Messages
select distinct m.idmessageprovider,isnull(td.idtransferclosed,0) idtransfer,isnull(idagent,0) idagent 
from [msg].[MessageSubcribers] s with (nolock)
join msg.[messages] m with (nolock) on m.idmessage=s.idmessage
left join TransferClosedNoteNotification  TNN with (nolock) on TNN.idmessage=s.idmessage
left join TransferClosedNote TN with (nolock) on TNN.IdTransferclosedNote = TN.IdTransferclosedNote	
left join TransferclosedDetail TD with (nolock) on TN.IdTransferclosedDetail = TD.IdTransferclosedDetail
left join AgentNotificacionReminder a with (nolock) on a.idmessage=s.idmessage
--where idmessagestatus in (1,2) and idmessageprovider in (2,4)
where idmessagestatus in (1,2) and idmessageprovider in (2)
order by idmessageprovider


--delete from #Messages where idtransfer!=8438617
--select * from #Messages
--return

 While exists (Select 1 from #Messages)      
    Begin      
        Select top 1 @idmessage=idmessage,@idmessageprovider=idmessageprovider,@idtransfer=idtransfer,@idagent=idagent from #Messages            
       
        if @idmessageprovider=2 and @idtransfer>0
        begin
            if exists (select 1 from [transfer] with (nolock) where idtransfer=@idtransfer and idstatus in (30,31,22))
            begin
                EXEC  [dbo].[st_DismissComplianceNotificationByIdTransfer]
		              @IdTransfer,
                      1,
                      @HasError,
                      @MessageOut
            end
            else
                if exists (select 1 from transferclosed with (nolock) where idtransferclosed=@idtransfer and idstatus in (30,31,22))
                begin
                      EXEC  [dbo].[st_DismissComplianceNotificationByIdTransfer]
		              @IdTransfer,
                      1,
                      @HasError,
                      @MessageOut
                end
        end
        else
            if @idmessageprovider=4 and @idagent>0
            begin                
                if exists (select 1 from agentdeposit with (nolock) where idagent=@idagent and [dbo].[RemoveTimeFromDatetime](DateOfLastChange)=@date and amount>0)
                begin
                       EXEC	[dbo].[st_DismissNotificationReminder]
		                    @IdAgent,
		                    1,
		                    @HasError,
		                    @MessageOut
                end
            end
    
        Delete #Messages where idmessage=@idmessage      
    END

drop table #Messages
END TRY
BEGIN CATCH
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) VALUES ('dbo.DissmissNotification',getdate(),ERROR_MESSAGE());
END CATCH

