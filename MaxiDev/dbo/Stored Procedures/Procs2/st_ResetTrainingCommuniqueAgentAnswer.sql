CREATE PROCEDURE [dbo].[st_ResetTrainingCommuniqueAgentAnswer]
(
	@IdTrainingCommuniqueAgentAnswer		INT OUT,
	@IdUser									INT,

	@HasError								BIT OUT,
	@Message								NVARCHAR(200) OUT
)
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		UPDATE TrainingCommuniqueAgentAnswer SET
			Acknowledgement = 0,
			ReviewDate = NULL,
			IdUserReviewed = NULL
		WHERE IdTrainingCommuniqueAgentAnswer = @IdTrainingCommuniqueAgentAnswer

		INSERT INTO TrainingCommuniqueAgentLog
		(
			IdTrainingCommuniqueAgentAnswer, 
			[Action], 
			LogDate, 
			IdUser
		)
		VALUES 
		(
			@IdTrainingCommuniqueAgentAnswer, 
			'Restart',
			GETDATE(),
			@IdUser
		)

		SET @HasError = 0
		SET @Message = NULL
		
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @MSG_ERROR NVARCHAR(500) = ERROR_MESSAGE();

		SET @HasError = 1
		SET @Message = 'Error when trying to reset TrainingCommuniqueAgentAnswer'

		INSERT INTO ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage)
		VALUES(OBJECT_NAME(@@PROCID), GETDATE(), @MSG_ERROR);
	END CATCH
END
