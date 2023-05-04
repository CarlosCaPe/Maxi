CREATE PROCEDURE [Corp].[st_DeleteCompetitionByAgent_InternalSalesMonitor]
@IdAgent AS INT,
@IdCompetition AS INT,
@EnterByIdUser INT,
@HasError BIT OUT,
@Message VARCHAR(MAX) out
AS
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="04/10/2019" Author="jzuniga">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

BEGIN TRY
	SET @HasError = 0;
	SET @Message ='';
	DECLARE @CreationDate DATETIME;
	SET @CreationDate = GETDATE();
	DECLARE @IdAgentApplication AS INT = 0
	SET @IdAgentApplication = (SELECT TOP 1 IdAgentApplication FROM RelationAgentApplicationWithAgent WITH(NOLOCK) WHERE IdAgent = @IdAgent)
	IF (@IdAgentApplication > 0)
	BEGIN
		DELETE FROM AgentApplicationCompetition
		WHERE IdAgentApplicationCompetition = @IdCompetition
	END
	ELSE
	BEGIN 
		DELETE FROM [InternalSalesMonitor].[AgentCompetition]
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

