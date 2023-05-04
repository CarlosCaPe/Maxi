CREATE PROCEDURE [Corp].[st_UpdateAgentExclude]
(
	@IdAgent int,
	@IdUser int,
	@ExcludeReportSignatureHold bit,
	@IsSaved bit out,
	@Message nvarchar(max) out
)
AS  

Set nocount on;
Begin try
	if exists(select 1 from Agent with(nolock) where IdAgent = @IdAgent)
		begin 
			update Agent set ExcludeReportSignatureHold = @ExcludeReportSignatureHold, EnterByIdUser = @IdUser, DateOfLastChange = GETDATE() where IdAgent = @IdAgent
			Set @IsSaved = 1
			Set @Message = 'Agent has been successfully saved'
		end
	else
		begin
			Set @IsSaved = 0
			Set @Message = 'Agent dont exist'
		end
End try
Begin Catch    
	Set @IsSaved = 0
	Set @Message = 'Error trying update agent exclude'
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_UpdateAgentExclude',Getdate(),@ErrorMessage);
End catch
