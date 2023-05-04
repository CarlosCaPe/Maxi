CREATE Procedure [dbo].[st_AgentApplicationChangeStatus]
(
@IdAgentApplication int,
@ToIdStatus int,
@EnterByIdUser int,
@Note nvarchar(max),
@IsValid bit Output
)   
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

Declare @FromIdStatus int
Declare @IdUserSeller int
Declare @AgentCode nvarchar(100)
Declare @StausName nvarchar(max)
Declare @IsStatusHold bit
Declare @NotificationType int
set @NotificationType=1
Select @FromIdStatus=IdAgentApplicationStatus, @AgentCode= AgentCode, @IdUserSeller=IdUserSeller  From AgentApplications with(nolock) where IdAgentApplication=@IdAgentApplication

If Exists (Select 1 from AgentAppValidStatusTransition with(nolock) where FromIdStatus=@FromIdStatus and ToIdStatus=@ToIdStatus )
	Begin
		Set @IsValid=1 
		Update AgentApplications set IdAgentApplicationStatus=@ToIdStatus, 
		EnterByIdUser= @EnterByIdUser, DateOfLastChange= GETDATE()
		where IdAgentApplication=@IdAgentApplication;
		
		--Add status history 
		Insert AgentApplicationStatusHistory (IdAgentApplication,IdAgentApplicationStatus, DateOfMovement, Note, DateOfLastChange, IdUserLastChange)
		Values (@IdAgentApplication, @ToIdStatus, GETDATE(),@Note, GETDATE(),@EnterByIdUser);
		
		If(@ToIdStatus=17)
		BEGIN
			set @NotificationType=3
			update PendingFilesAgentApp set SendNotification = 0 where IdAgentApplication = @IdAgentApplication; -- New RMM
		END
		IF(@ToIdStatus=18)
		BEGIN
			set @NotificationType=4
		END
		--Insert notification 
		Insert Notifications (IdAgentApplication, idSeller,IdNotificationType, Title, ReadedByUser, DateOfLastchange, IdUserLastChange)
		Values (@IdAgentApplication, @IdUserSeller, @NotificationType,'Agent Application ' +@AgentCode+ ' status has changed.',0,GETDATE(),1);
		
	End
Else
	Begin
		Set @IsValid=0
	End
