CREATE PROCEDURE [dbo].[st_UpdateValueGlobalAttributes]
(
	@ValueGlobalA 			NVARCHAR(max),
	@NameGlobalA 			NVARCHAR(max)
)
AS
BEGIN
BEGIN TRANSACTION
	BEGIN TRY 
			
			
		UPDATE dbo.GlobalAttributes SET VALUE = @ValueGlobalA
		WHERE Name = @NameGlobalA;
			

		  SELECT [Name],[Value],[Description] FROM dbo.GlobalAttributes
			WHERE Name = @NameGlobalA

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION


		INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
		VALUES(OBJECT_NAME(@@PROCID), GETDATE(), 'An unexpected error occurred while updating GlobalAttributes')

	END CATCH
END