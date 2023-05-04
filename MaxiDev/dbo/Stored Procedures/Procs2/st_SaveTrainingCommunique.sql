CREATE PROCEDURE st_SaveTrainingCommunique
(
	@IdTrainingCommunique		INT OUT,
	@StartDate					DATETIME,
	@EndingDate					DATETIME,
	@Title						VARCHAR(200),
	@Description				VARCHAR(200),
	@IdStatus					INT,
	@IdUser						INT,

	@HasError					BIT OUT,
	@Message					NVARCHAR(200) OUT
)
AS
BEGIN
	IF ISNULL(@IdTrainingCommunique, 0) > 0 AND NOT EXISTS (SELECT * FROM TrainingCommunique tc WHERE tc.IdTrainingCommunique = @IdTrainingCommunique)
		SET @Message = CONCAT('The record with the Id (', @IdTrainingCommunique, ') does not exist')

	IF ISNULL(@Message, '') <> ''
	BEGIN
		SET @HasError = 1
		RETURN
	END

	BEGIN TRANSACTION
	BEGIN TRY

		IF ISNULL(@IdTrainingCommunique, 0) > 0
			UPDATE TrainingCommunique SET
				StartDate = @StartDate,
				EndingDate = @EndingDate,
				Title = @Title,
				Description = @Description,
				IdStatus = @IdStatus
			WHERE IdTrainingCommunique = @IdTrainingCommunique
		ELSE
		BEGIN
			INSERT INTO TrainingCommunique
			(
				StartDate, 
				EndingDate, 
				Title, 
				Description, 
				IdStatus, 
				CreationDate, 
				IdUser
			)
			VALUES 
			(
				@StartDate,
				@EndingDate,
				@Title, 
				@Description,
				@IdStatus,
				GETDATE(),
				@IdUser
			)

			SET @IdTrainingCommunique = @@identity
		END

		INSERT INTO TrainingCommuniqueAgentAnswer
		(
			IdTrainingCommunique,
			IdAgent,
			Acknowledgement,
			ReviewDate,
			IdUserReviewed,
			CreationDate,
			IdUser
		)
		SELECT 
			@IdTrainingCommunique,
			a.IdAgent,
			0,
			NULL,
			NULL,
			GETDATE(),
			@IdUser
		FROM Agent a
		WHERE a.IdAgentStatus = 1
		AND NOT EXISTS (SELECT 1 FROM TrainingCommuniqueAgentAnswer ta WHERE ta.IdAgent = a.IdAgent AND ta.IdTrainingCommunique = @IdTrainingCommunique)

		SET @HasError = 0
		SET @Message = NULL
		
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @MSG_ERROR NVARCHAR(500) = ERROR_MESSAGE();

		SET @HasError = 1
		SET @Message = 'Error when trying to create TrainingCommunique'

		INSERT INTO ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage)
		VALUES(OBJECT_NAME(@@PROCID), GETDATE(), @MSG_ERROR);
	END CATCH
END