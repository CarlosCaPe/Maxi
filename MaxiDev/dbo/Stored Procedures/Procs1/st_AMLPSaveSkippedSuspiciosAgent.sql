CREATE PROCEDURE [dbo].[st_AMLPSaveSkippedSuspiciosAgent] 
(
	@IdAgent		INT,
	@IdCountry		INT,
	@IdUser			INT,
	@Notes			VARCHAR(1000),
	@HasError		BIT OUT,
	@ResultMessage	NVARCHAR(MAX) OUT
)
AS
BEGIN

	DECLARE @CurrentDate	DATETIME,
			@MonitorMinutes	INT

	SET @CurrentDate = GETDATE()
	
	SELECT TOP 1
		@MonitorMinutes = ms.Value
	FROM AMLP_MonitorSettings ms 
	WHERE ms.IdMonitorSettings = 1

	BEGIN TRY

		DECLARE @Agent TABLE
		(
			IdAgent		INT,
			IdCountry	INT,
			DateStopped	DATETIME,
			DateResume	DATETIME
		)
		
		INSERT INTO AMLP_SkippedSuspiciousAgent
		(
			IdAgent, 
			IdCountry, 
			DateStopped, 
			DateResume, 
			IdUser,
			Notes
		)
		OUTPUT INSERTED.IdAgent, INSERTED.IdCountry, INSERTED.DateStopped, INSERTED.DateResume 
		INTO @Agent(IdAgent, IdCountry, DateStopped, DateResume)
		VALUES
		(
			@IdAgent,
			@IdCountry,
			@CurrentDate,
			DATEADD(MINUTE, @MonitorMinutes, @CurrentDate),
			@IdUser,
			@Notes
		)

		DELETE FROM AMLP_SuspiciousAgentCurrent 
		WHERE IdAgent = @IdAgent AND IdCountry = @IdCountry

		SET @HasError = 0

		SELECT 
			@ResultMessage = CONCAT(
				'Transactions directed to "',
				c.CountryName,
				'" of agent "',
				a.AgentCode,
				'" between (', convert(varchar, ssa.DateStopped, 22), ')',
				' and (', convert(varchar, ssa.DateResume, 22), ')',
				' will are omitted for suspicious agent monitor'
			)
		FROM @Agent ssa 
			JOIN Agent a ON a.IdAgent = ssa.IdAgent
			JOIN Country c ON c.IdCountry = ssa.IdCountry
		
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(MAX)         
		SELECT @ErrorMessage=ERROR_MESSAGE()        
		SET @HasError = 1

		RAISERROR(@ErrorMessage, 16, 1);
	END CATCH
END
