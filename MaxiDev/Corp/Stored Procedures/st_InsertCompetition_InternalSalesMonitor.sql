CREATE PROCEDURE [Corp].[st_InsertCompetition_InternalSalesMonitor]
@IdAgent AS INT,
@Transmitter AS VARCHAR(MAX),
@Country AS VARCHAR(MAX), 
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

	IF (SELECT COUNT(1) FROM CompetitionTransmitter WITH(NOLOCK) WHERE UPPER(LTRIM(RTRIM(Name))) = UPPER(LTRIM(RTRIM(@Transmitter)))) = 0
		INSERT INTO CompetitionTransmitter (Name, DateOfLastChange, EnterByIdUser, IdGenericStatus)
		VALUES (@Transmitter, @CreationDate, @EnterByIdUser, 1)
	
	DECLARE @IdAgentApplication AS INT = 0
	SET @IdAgentApplication = (SELECT TOP 1 IdAgentApplication FROM RelationAgentApplicationWithAgent WITH(NOLOCK) WHERE IdAgent = @IdAgent)
	IF (@IdAgentApplication > 0)
	BEGIN
		IF (SELECT TOP 1 1 FROM [AgentApplicationCompetition] WITH(NOLOCK) WHERE IdAgentApplication = @IdAgentApplication AND Country = @Country AND Transmitter = @Transmitter) > 0
		BEGIN 
			SET @HasError = 1;
			SET @Message ='The transmitter and country, are already registered.'
			RAISERROR(@Message,16,1);
		END
		ELSE
			INSERT INTO [AgentApplicationCompetition] (IdAgentApplication, Transmitter, Country, FxRate, TransmitterFee, MaxiFee, EnterByIdUser, DateOfLastChange)
			VALUES (@IdAgentApplication, @Transmitter, @Country, 0, 0, 0, @EnterByIdUser, @CreationDate)
	END
	ELSE
	BEGIN 
		IF (SELECT TOP 1 1 FROM [InternalSalesMonitor].[AgentCompetition] WITH(NOLOCK) WHERE IdAgent = @IdAgent AND Country = @Country AND Transmitter = @Transmitter) > 0
		BEGIN 
			SET @HasError = 1;
			SET @Message ='The transmitter and country, are already registered'
			RAISERROR(@Message,16,1);
		END
		ELSE
			INSERT INTO [InternalSalesMonitor].[AgentCompetition] (IdAgent, Transmitter, Country, FxRate, TransmitterFee, MaxiFee, EnterByIdUser, DateOfLastChange)
			VALUES (@IdAgent, @Transmitter, @Country, 0, 0, 0, @EnterByIdUser, @CreationDate)
	END
END TRY
BEGIN CATCH
	SET @HasError = 1;
	DECLARE @ErrorMessage NVARCHAR(MAX);
	SELECT @ErrorMessage = ERROR_MESSAGE();
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) 
	VALUES ('Corp.st_InsertCompetition_InternalSalesMonitor',Getdate(),@ErrorMessage);
END CATCH
