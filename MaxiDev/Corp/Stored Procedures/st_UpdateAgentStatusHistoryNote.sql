CREATE PROCEDURE  [Corp].[st_UpdateAgentStatusHistoryNote] 
(
			
			@IdAgent int 
           ,@IdUser int
		   ,@Note varchar(max)
		   ,@HasError bit out
		   ,@Message varchar(max) out
		  
)
	as
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY
	DECLARE @IdAgentStatus int
	SET @Message= 'Operation was performed successfully'
	SET @HasError=0;
	SELECT TOP 1 @IdAgentStatus = IdAgentStatus FROM Agent with (nolock) WHERE IdAgentStatus <> 0 AND IdAgent=@IdAgent
	IF (@IdAgentStatus>0)
	BEGIN 
	UPDATE [dbo].[AgentStatusHistory]
	   SET [IdUser] = @IdUser
		  ,[IdAgentStatus] = @IdAgentStatus
		  ,[DateOfchange] = GETDATE()
		  ,[Note] = @Note
      
	 WHERE IdAgent = @IdAgent
	END
	ELSE
	BEGIN
	SET @Message= 'Agent doesnt exists'
	SET @HasError=1;
	END
	

	END TRY
	BEGIN CATCH
	SET @HasError=1;
	declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()   
	SET @Message= @ErrorMessage                                          
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_UpdateAgentStatusHistoryNote]',Getdate(),@ErrorMessage)                                                                                            
	END CATCH 

END
