CREATE PROCEDURE  [Corp].[st_AddAgentStatusHistoryNote] 
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

	INSERT INTO [dbo].[AgentStatusHistory]
           ([IdUser]
           ,[IdAgent]
           ,[IdAgentStatus]
           ,[DateOfchange]
           ,[Note]
           )
     VALUES
           (@IdUser
           ,@IdAgent
           ,@IdAgentStatus
           ,GETDATE()
           , @Note)

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
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_AddAgentStatusHistoryNote]',Getdate(),@ErrorMessage)                                                                                            
	END CATCH 

END
