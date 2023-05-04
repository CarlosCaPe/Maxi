CREATE PROCEDURE st_ViewCommunique
(
	@IdTrainingCommuniqueAgentAnswer		INT,
	@IdUser									INT,
	
	@HasError								BIT OUT,
	@Message								NVARCHAR(200) OUT
)
AS
BEGIN
	BEGIN TRY
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
			'View',
			GETDATE(),
			@IdUser
		)
		
		SET @HasError = 0
		SET @Message = NULL
	END TRY
	BEGIN CATCH
		DECLARE @MSG_ERROR NVARCHAR(500) = ERROR_MESSAGE();

		SET @HasError = 1
		SET @Message = 'Error when trying to view communique'

		INSERT INTO ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage)
		VALUES(OBJECT_NAME(@@PROCID), GETDATE(), @MSG_ERROR);
	END CATCH
END