CREATE PROCEDURE [dbo].[st_UpdateAgentSeller]
(
	@IdSeller	    INT,
	@Agents		    XML,
	@Message		VARCHAR(500)=NULL,
	@IdUser			INT=NULL,

	@Success		BIT OUT,
	@ErrorMessage	VARCHAR(200) OUT
)
AS
BEGIN
BEGIN TRANSACTION
	BEGIN TRY

		;WITH UpdateAgentSeller AS
		(
			SELECT
	            t.c.value('.', 'int') Id
                FROM @Agents.nodes('root/Id') t(c)
		)
	--SELECT * FROM Seller
		UPDATE Agent SET
			Agent.IdUserSeller = @IdSeller
			--Agent.IdUserSeller = 555
		--OUTPUT INSERTED.*
		FROM UpdateAgentSeller u
		WHERE 
			Agent.IdAgent = u.Id
			

		SELECT	@Success = 1,
				@ErrorMessage = NULL

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		SELECT	@Success = 0,
				@ErrorMessage = 'An unexpected error occurred while updating Agent'

		DECLARE @ExMessage VARCHAR(1000) = ERROR_MESSAGE()
		INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
		VALUES(OBJECT_NAME(@@PROCID), GETDATE(), @ExMessage)

	END CATCH
END
