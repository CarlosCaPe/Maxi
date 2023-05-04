CREATE PROCEDURE Soporte.st_SendAllTransferAnalisysReports
(
	@CurrentDate	DATETIME = NULL
)
AS
BEGIN
	DECLARE @DateFrom		DATE,
			@DateTo			DATE,
			@HasError		BIT,
			@ErrorMessage	VARCHAR(2000),
			@DayNumber		INT

	DECLARE @StatusReport TABLE(Id INT IDENTITY, IdStatus INT, IsBiweekly BIT NOT NULL)

	INSERT INTO @StatusReport
	VALUES
	(9, 0),
	(10, 0),
	(14, 0),
	(15, 0),
	(12, 1),
	(13, 1)

	IF @CurrentDate IS NULL
		SET @CurrentDate = GETDATE()

	SET @DayNumber = DATEPART(DAY, @CurrentDate)


	IF @DayNumber NOT IN (1, 2, 16)
		DELETE FROM @StatusReport 
	ELSE IF @DayNumber = 1
		DELETE FROM @StatusReport WHERE IsBiweekly = 1
	ELSE IF @DayNumber IN (2, 16)
		DELETE FROM @StatusReport WHERE IsBiweekly = 0

	DECLARE @CurrentId		INT,
			@CurrentStatus	INT,
			@ReportName		VARCHAR(200)


	WHILE EXISTS(SELECT 1 FROM @StatusReport)
	BEGIN
		SELECT TOP 1
			@CurrentId = sr.Id,
			@CurrentStatus = sr.IdStatus
		FROM @StatusReport sr

		SET @DateFrom = DATEADD(MONTH, -1, @CurrentDate)
		SET @DateFrom = DATEFROMPARTS(DATEPART(YEAR, @DateFrom), DATEPART(MONTH, @DateFrom), 1)

		SET @DateTo = DATEADD(DAY, -1, DATEADD(MONTH, 1, @DateFrom))

		IF EXISTS(SELECT 1 FROM @StatusReport sr WHERE sr.Id = @CurrentId AND sr.IsBiweekly = 1)
		BEGIN
			IF @DayNumber = 16
				SET @DateTo = DATEFROMPARTS(DATEPART(YEAR, @DateTo), DATEPART(MONTH, @DateTo), 15)
			ELSE
				SET @DateFrom = DATEFROMPARTS(DATEPART(YEAR, @DateFrom), DATEPART(MONTH, @DateFrom), 16)
		END

		SELECT @CurrentStatus, @DateFrom, @DateTo
		EXEC Soporte.st_SendTransferAnalisysReport @CurrentStatus, @DateFrom, @DateTo, 'jcsierra@maxi-ms.com;iuliocesars@gmail.com'

		DELETE FROM @StatusReport WHERE Id = @CurrentId
	END
END


