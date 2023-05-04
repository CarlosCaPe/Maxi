CREATE PROCEDURE [Corp].[st_AgentAddHistoryStatusNote]
(
    @IdAgent int,
    @IdAgentStatus int,
    @EnterByIdUser int,
    @Note nvarchar(max),
	@IdType int,
	@HasError bit out,
    @ResultMessage nvarchar(max) out)
as
begin try
insert into AgentOfacNoteHistory
(IdAgent,IdAgentStatus,DateOfMovement,Note,DateOfLastChange,IdUserLastChange, IdType)
values
(@IdAgent,@IdAgentStatus,getdate(),@Note,getdate(),@EnterByIdUser, @IdType)

SET @HasError =0
SELECT @ResultMessage='Operation Successfull'

end try
begin catch       
    set @HasError =1                                                                                    
    Select @ResultMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_AgentAddHistoryStatusNote]',Getdate(),@ResultMessage)
end catch
