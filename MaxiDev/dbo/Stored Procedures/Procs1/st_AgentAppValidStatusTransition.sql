CREATE Procedure [dbo].[st_AgentAppValidStatusTransition]
(
    @IdAgentApplication int,
    @ToIdStatus int,
    @EnterByIdUser int,
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
Declare @AgentCode nvarchar(100)
Declare @StausName nvarchar(max)
Declare @IsStatusHold bit
Select @FromIdStatus=IdAgentApplicationStatus, @AgentCode= AgentCode From AgentApplications with(nolock) where IdAgentApplication=@IdAgentApplication

select @IsStatusHold=IsHold,@StausName=StatusName from AgentApplicationStatuses with(nolock) where IdAgentApplicationStatus=@ToIdStatus

Select @IdAgentApplication,@ToIdStatus


--INSERT ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage)
--VALUES('st_AgentAppValidStatusTransition', GETDATE(), CONCAT('@IdAgentApplication =', @IdAgentApplication, '@ToIdStatus =', @ToIdStatus, '@EnterByIdUser =', @EnterByIdUser))

if (@ToIdStatus=20 and exists (select 1 from AgentApplicationStatusHistory with(nolock) where IdAgentApplication=@IdAgentApplication and IdAgentApplicationStatus=16))
begin
     Set @IsValid=1 
     set @ToIdStatus = 16
     select @IsStatusHold=IsHold,@StausName=StatusName from AgentApplicationStatuses with(nolock) where IdAgentApplicationStatus=@ToIdStatus;

     Update AgentApplications set IdAgentApplicationStatus=@ToIdStatus, 
	 EnterByIdUser= @EnterByIdUser, DateOfLastChange= GETDATE()
	 where IdAgentApplication=@IdAgentApplication;

     Insert AgentApplicationStatusHistory (IdAgentApplication,IdAgentApplicationStatus, DateOfMovement, Note, DateOfLastChange, IdUserLastChange)
		    Values (@IdAgentApplication, @ToIdStatus, GETDATE(),@StausName, GETDATE(),@EnterByIdUser);
end
else
begin
    If Exists (Select 1 from AgentAppValidStatusTransition with(nolock) where FromIdStatus=@FromIdStatus and ToIdStatus=@ToIdStatus )
	    Begin
	PRINT '1'
		    Set @IsValid=1 
		    Update AgentApplications set IdAgentApplicationStatus=@ToIdStatus, 
		    EnterByIdUser= @EnterByIdUser, DateOfLastChange= GETDATE()
		    where IdAgentApplication=@IdAgentApplication;
	
		    --Add status history 
		    Insert AgentApplicationStatusHistory (IdAgentApplication,IdAgentApplicationStatus, DateOfMovement, Note, DateOfLastChange, IdUserLastChange)
		    Values (@IdAgentApplication, @ToIdStatus, GETDATE(),@StausName, GETDATE(),@EnterByIdUser);
		
		    --If (@IsStatusHold=1)
		    --Begin 
		    --	--Insert notification 
		    --	Insert Notifications (IdAgentApplication, idSeller,IdNotificationType, Title, ReadedByUser, DateOfLastchange, IdUserLastChange)
		    --	Values (@IdAgentApplication, @EnterByIdUser, 1,'Agent Application ' +@AgentCode+ ' has been changed to status hold',0,GETDATE(),1)
		    --End
			
	    End
    Else
	    Begin
		    Set @IsValid=0
	    End
end
