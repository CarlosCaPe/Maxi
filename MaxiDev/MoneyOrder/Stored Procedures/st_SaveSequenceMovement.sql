CREATE PROCEDURE MoneyOrder.st_SaveSequenceMovement
(
	@IdAgent				INT,
	@InitialSequence		BIGINT,
	@FinalSequence			BIGINT,
	@IdSequenceMovementType	INT,
	@Notes					VARCHAR(500),

	@EnterByIdUser			INT,
	@IdLanguage				INT
)
AS
BEGIN
	DECLARE @MSG_ERROR NVARCHAR(500)

	BEGIN TRY
		IF @InitialSequence > @FinalSequence
		BEGIN
			SELECT 
				1 Success,
				dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage,'MO_StartSequenceCannotBeGreaterThanEnd') [Message]
			RETURN;
		END

		DECLARE @CurrentDate DATETIME = GETDATE(),
				@IdSequenceStatusAvailable INT = 1,
				@IdSequenceStatusRemoved INT = 2
		
		;WITH GenerateNumbers AS (
			SELECT @InitialSequence AS Number
			UNION ALL
			SELECT Number + 1 FROM GenerateNumbers
			WHERE Number + 1 <= @FinalSequence
		)
		SELECT Number 
		INTO #tmpSequences 
		FROM GenerateNumbers
		OPTION (MAXRECURSION 0);

		-- Validate Movement
		IF (@IdSequenceMovementType = 1)
		BEGIN
			IF EXISTS(
				SELECT 1 FROM MoneyOrder.[Sequence] s WITH(NOLOCK)
					JOIN MoneyOrder.SequenceMovement sm WITH(NOLOCK) ON sm.IdSequenceMovement = s.IdSequenceMovement
				WHERE sm.IdAgent = @IdAgent
				AND s.IdSequenceStatus = @IdSequenceStatusAvailable
			)
				SET @MSG_ERROR = dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage,'MO_AgentAlreadyHasSequencesLoaded');
			ELSE IF EXISTS(
				SELECT 1 FROM MoneyOrder.[Sequence] s WITH(NOLOCK)
					JOIN MoneyOrder.SequenceMovement sm WITH(NOLOCK) ON sm.IdSequenceMovement = s.IdSequenceMovement
					JOIN #tmpSequences ts ON ts.Number = s.[Sequence]
				WHERE sm.IdAgent = @IdAgent
			)
				SET @MSG_ERROR = dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage,'MO_AgentAlReadyHaveSelectedRange');
		END 
		ELSE IF (@IdSequenceMovementType = 2)
		BEGIN
			IF EXISTS(
				SELECT 1 FROM MoneyOrder.[Sequence] s WITH(NOLOCK)
					JOIN MoneyOrder.SequenceMovement sm WITH(NOLOCK) ON sm.IdSequenceMovement = s.IdSequenceMovement
					JOIN #tmpSequences ts ON ts.Number = s.[Sequence]
				WHERE sm.IdAgent = @IdAgent
				AND s.IdSequenceStatus = @IdSequenceStatusRemoved
			)
				SET @MSG_ERROR = dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage,'MO_AgentAlReadyHaveRemovedRange');
			ELSE IF NOT EXISTS
			(
				SELECT 1 FROM MoneyOrder.[Sequence] s WITH(NOLOCK)
					JOIN MoneyOrder.SequenceMovement sm WITH(NOLOCK) ON sm.IdSequenceMovement = s.IdSequenceMovement
					JOIN #tmpSequences ts ON ts.Number = s.[Sequence]
				WHERE sm.IdAgent = @IdAgent
				AND s.IdSequenceStatus = @IdSequenceStatusAvailable
			)
				SET @MSG_ERROR = dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage,'MO_AgentNotHaveRecordsToRemoved');
			ELSE IF EXISTS
			(
				SELECT 1 FROM MoneyOrder.[Sequence] s WITH(NOLOCK)
					JOIN MoneyOrder.SequenceMovement sm WITH(NOLOCK) ON sm.IdSequenceMovement = s.IdSequenceMovement
					JOIN #tmpSequences ts ON ts.Number = s.[Sequence]
				WHERE sm.IdAgent = @IdAgent
				AND s.IdSequenceStatus <> @IdSequenceStatusAvailable
			)
				SET @MSG_ERROR = dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage,'MO_SomeRecordsInRangeCannotDeleted');
		END

		IF ISNULL(@MSG_ERROR, '') <> ''
		BEGIN
			SELECT 
				0 Success,
				@MSG_ERROR [Message]
			RETURN;
		END

		-- Create Movement
		INSERT INTO MoneyOrder.SequenceMovement
		(
			IdAgent,
			InitialSequence,
			FinalSequence,
			IdSequenceMovementType,
			Notes,
			CreationDate,
			DateOfLastChange,
			EnterByIdUser
		)
		VALUES
		(
			@IdAgent,
			@InitialSequence,
			@FinalSequence,
			@IdSequenceMovementType,
			@Notes,
			@CurrentDate,
			@CurrentDate,
			@EnterByIdUser
		);

		DECLARE @IdSequenceMovement INT = @@identity;

		-- INSERT / UPDATE Sequences
		CREATE TABLE #ModifiedSequences(IdSequence BIGINT, IdSequenceStatus INT)
		IF (@IdSequenceMovementType = 1)
			INSERT INTO MoneyOrder.[Sequence]
			(
				IdSequenceMovement, 
				[Sequence],
				IdSequenceStatus,
				CreationDate,
				DateOfLastChange,
				EnterByIdUser
			)
			OUTPUT INSERTED.IdSequence, INSERTED.IdSequenceStatus 
			INTO #ModifiedSequences(IdSequence, IdSequenceStatus)
			SELECT
				@IdSequenceMovement,
				ts.Number,
				@IdSequenceStatusAvailable,
				@CurrentDate,
				@CurrentDate,
				@EnterByIdUser
			FROM #tmpSequences ts
		ELSE IF (@IdSequenceMovementType = 2)
			UPDATE s SET
				s.IdSequenceStatus = @IdSequenceStatusRemoved
			OUTPUT INSERTED.IdSequence, INSERTED.IdSequenceStatus 
			INTO #ModifiedSequences(IdSequence, IdSequenceStatus)
			FROM MoneyOrder.[Sequence] s
			WHERE EXISTS(SELECT 1 FROM #tmpSequences ts WHERE ts.Number = s.[Sequence])
		
		-- Add log detail
		INSERT INTO MoneyOrder.SequenceDetail
		(
			IdSequence, 
			IdSequenceStatus, 
			CreationDate, 
			EnterByIdUser
		)
		SELECT 
			s.IdSequence,
			s.IdSequenceStatus,
			@CurrentDate,
			@EnterByIdUser
		FROM #ModifiedSequences s

		SELECT 
			1 Success,
			dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage,'GenericOkSave') [Message]
	END TRY
	BEGIN CATCH
		IF(ISNULL(@MSG_ERROR, '') = '')
			SET @MSG_ERROR = ERROR_MESSAGE();

		SELECT 
			0 Success,
			dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage,'GenericErrorSave') [Message]

		INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) 
		VALUES(ERROR_PROCEDURE() ,GETDATE(), @MSG_ERROR);
	END CATCH
END