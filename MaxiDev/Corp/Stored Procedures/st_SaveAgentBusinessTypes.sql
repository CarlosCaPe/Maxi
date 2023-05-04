CREATE PROCEDURE [Corp].[st_SaveAgentBusinessTypes]
(
    @AgentCode [nvarchar](MAX),
    @AgentBusinessTypes XML,	
	@EnterByIdUser [int],
    @HasError BIT OUT
)
AS

BEGIN TRY

SET @HasError=0

IF (SELECT TOP 1 1 FROM RelationAgentBusinessType WITH(NOLOCK) WHERE AgentCode = @AgentCode) > 0
BEGIN 
	UPDATE dbo.RelationAgentBusinessType SET BusinessTypes = @AgentBusinessTypes, IdUserLastChange = @EnterByIdUser, DateOfLastChange = GETDATE() WHERE AgentCode = @AgentCode
END
ELSE
BEGIN
	INSERT INTO dbo.RelationAgentBusinessType	
           ([AgentCode]
           ,[BusinessTypes]
           ,[DateOfLastChange]
           ,[IdUserLastChange])
     VALUES
           (@AgentCode
           ,@AgentBusinessTypes
           ,GETDATE()
           ,@EnterByIdUser)
END
END TRY
BEGIN CATCH
    SET @HasError=1    
    DECLARE @ErrorMessage NVARCHAR(MAX)
    SELECT @ErrorMessage = ERROR_MESSAGE()                                             
    INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) VALUES ('[Corp].[st_SaveAgentBusinessTypes]', GETDATE(), @ErrorMessage)   
END CATCH
