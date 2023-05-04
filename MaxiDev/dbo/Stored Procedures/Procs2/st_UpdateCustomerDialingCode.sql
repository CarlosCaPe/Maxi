CREATE PROCEDURE [dbo].[st_UpdateCustomerDialingCode]
(
	@IdCustomer	 			    INT,
	@IdDialigCode		           	INT,
	@Success				BIT OUT,
	@ErrorMessage			VARCHAR(200) OUT
)
AS
BEGIN
BEGIN TRANSACTION
	BEGIN TRY 
			
		
		UPDATE Customer SET
			Customer.IdDialingCodePhoneNumber = @IdDialigCode
		WHERE 
			Customer.IdCustomer = @IdCustomer	
			

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