CREATE PROCEDURE st_AcceptCommunique
(
	@IdTrainingCommuniqueAgentAnswer		INT,
	@IdUser									INT,

	@IdLanguage								INT,
	
	@HasError								BIT OUT,
	@Message								NVARCHAR(200) OUT
)
AS
BEGIN
	BEGIN TRY
		DECLARE @CurrentDate DATETIME = GETDATE()

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
			'Acknowledgement',
			@CurrentDate,
			@IdUser
		)

		UPDATE TrainingCommuniqueAgentAnswer SET
			Acknowledgement = 1,
			ReviewDate = @CurrentDate,
			IdUserReviewed = @IdUser
		WHERE IdTrainingCommuniqueAgentAnswer = @IdTrainingCommuniqueAgentAnswer


		SELECT * FROM LenguageResource WHERE Message LIKE '%success%'


		SET @HasError = 0
		SET @Message = IIF(@IdLanguage = 1, 'Acknowledgment accepted', 'Comunicado aceptado')
	END TRY
	BEGIN CATCH

		DECLARE @MSG_ERROR NVARCHAR(500) = ERROR_MESSAGE();

		SET @HasError = 1
		SET @Message = 'Error when trying to accept communique'

		INSERT INTO ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage)
		VALUES(OBJECT_NAME(@@PROCID), GETDATE(), @MSG_ERROR);
	END CATCH
END