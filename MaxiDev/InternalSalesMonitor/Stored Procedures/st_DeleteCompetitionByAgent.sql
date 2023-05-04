CREATE PROCEDURE [InternalSalesMonitor].[st_DeleteCompetitionByAgent]
@IdAgent AS INT,
@IdCompetition AS INT,
@EnterByIdUser INT,
@HasError BIT OUT,
@Message VARCHAR(MAX) out
AS
BEGIN TRY
	SET @HasError = 0;
	SET @Message ='';
	DECLARE @CreationDate DATETIME;
	SET @CreationDate = GETDATE();
	DECLARE @IdAgentApplication AS INT = 0
	SET @IdAgentApplication = (SELECT TOP 1 IdAgentApplication FROM RelationAgentApplicationWithAgent WHERE IdAgent = @IdAgent)
	IF (@IdAgentApplication > 0)
	BEGIN
		DELETE FROM AgentApplicationCompetition
		WHERE IdAgentApplicationCompetition = @IdCompetition
	END
	ELSE
	BEGIN 
		DELETE FROM AgentCompetition
		WHERE IdAgentCompetition = @IdCompetition
	END
END TRY
BEGIN CATCH
	SET @HasError = 1;
	DECLARE @ErrorMessage NVARCHAR(MAX);
	SELECT @ErrorMessage = ERROR_MESSAGE();
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) 
	VALUES ('InternalSalesMonitor.st_DeleteCompetitionByAgent',Getdate(),@ErrorMessage);
END CATCH



