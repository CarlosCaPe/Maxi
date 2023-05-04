CREATE PROCEDURE [Corp].[st_AgentApplicationAddHistoryStatusNote]
(
    @IdAgentApplication int,
    @IdAgentApplicationStatus int,
    @EnterByIdUser int,
    @Note nvarchar(max),
	@IdType int = null
)
as
/********************************************************************
<Author>José Velarde</Author>
<app>Corporativo</app>
<Description>Agrega nota al Agent Application History</Description>

<ChangeLog>
<log Date="01/01/2014" Author="????"> Creación </log>
<log Date="25/01/2017" Author="jvelarde"> Se agrega idType para registros OFAC </log>
</ChangeLog>
*********************************************************************/
begin try
insert into AgentApplicationStatusHistory
(IdAgentApplication,IdAgentApplicationStatus,DateOfMovement,Note,DateOfLastChange,IdUserLastChange,Idtype)
values
(@IdAgentApplication,@IdAgentApplicationStatus,getdate(),@Note,getdate(),@EnterByIdUser,@IdType);
end try
begin catch
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_AgentApplicationAddHistoryStatusNote]',Getdate(),@ErrorMessage)
end catch
