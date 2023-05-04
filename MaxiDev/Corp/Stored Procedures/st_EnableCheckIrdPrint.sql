CREATE PROCEDURE [Corp].[st_EnableCheckIrdPrint]
@IdCheck	INT
AS

BEGIN

BEGIN TRY
	
	UPDATE CheckRejectHistory SET IrdPrinted = 0, DateofLastChange = getdate()
	WHERE IdCheck = @IdCheck
	
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage varchar(max);
    SELECT @ErrorMessage=ERROR_MESSAGE();
    INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)VALUES('st_GetUserByUserLogin',Getdate(),@ErrorMessage);
END CATCH


END

