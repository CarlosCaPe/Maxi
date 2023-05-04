CREATE PROCEDURE st_SetActiveTrainingCommunication
(
	@IdAgent					INT,
	@IdUser						INT
)
AS
BEGIN
	BEGIN TRY
		
		INSERT INTO TrainingCommuniqueAgentAnswer(IdTrainingCommunique, IdAgent, Acknowledgement, ReviewDate, IdUserReviewed, CreationDate, IdUser)
		SELECT
			tc.IdTrainingCommunique, 
			@IdAgent,
			0,
			NULL,
			NULL,
			GETDATE(),
			@IdUser
		FROM TrainingCommunique tc WITH(NOLOCK) 
		WHERE tc.Active = 1 
			AND NOT EXISTS (SELECT 1 FROM TrainingCommuniqueAgentAnswer ta WITH(NOLOCK) WHERE ta.IdAgent = @IdAgent AND ta.IdTrainingCommunique = tc.IdTrainingCommunique)

	END TRY
	BEGIN CATCH
		DECLARE @MSG_ERROR NVARCHAR(500) = ERROR_MESSAGE();

		INSERT INTO ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage)
		VALUES('st_SetActiveTrainingCommunication', GETDATE(), @MSG_ERROR);
	END CATCH
END
