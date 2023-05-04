CREATE PROCEDURE [Corp].[st_SaveAgentAuditDocumentsLog]
(
	@IdUser			INT,
	@IdState		INT,
	@Parameters		VARCHAR(max),
	@Result			VARCHAR(1000),
	@DateStart		DATETIME,
	@DateEnd		DATETIME,
	@DateOfCreation	DATETIME,
	@HasError 		BIT OUT,
	@MessageOut 	VARCHAR(max) OUT
)
AS
BEGIN
	
	BEGIN TRY
		DECLARE @StateCode VARCHAR(MAX)
		
		SET @HasError = 0
		SET @MessageOut = ''
		
		SELECT @StateCode = StateCode FROM State WITH(NOLOCK) WHERE IdState = @IdState
		
	
		INSERT INTO Corp.AgentAuditDocumentsLog (IdUser, StateCode, Parameters, Result, DateStart, DateEnd, DateOfCreation)
		VALUES (@IdUser, @StateCode, @Parameters, @Result, @DateStart, @DateEnd, @DateOfCreation)
	
	END TRY
	BEGIN CATCH
		SET @HasError = 1
		SET @MessageOut = Error_message()
		DECLARE @ErrorMessage varchar(max);
	    SELECT @ErrorMessage=ERROR_MESSAGE();
	    INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)VALUES('st_SaveAgentAuditDocumentsLog',Getdate(),@ErrorMessage);
	END CATCH	
	
END