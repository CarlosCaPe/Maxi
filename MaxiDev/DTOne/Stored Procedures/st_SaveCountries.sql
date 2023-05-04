-- =============================================
-- Author:		Oscar Cardenas
-- Create date: 10/02/2023
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [DTOne].[st_SaveCountries]
		@Countries AS [DTOne].[CountriesType] READONLY,
		@HasError AS bit out,
		@Message AS nvarchar(max) out
AS
BEGIN
	BEGIN TRY
	DECLARE @SystemUser int
	SELECT @SystemUser=[dbo].[GetGlobalAttributeByName] ( 'SystemUserID' ) 

		  MERGE INTO [DTOne].[Country] E1
		  USING @Countries E2
		  ON E1.CountryCode=E2.CountryCode
		  WHEN MATCHED THEN
		  UPDATE SET 
			 E1.CountryName = E2.CountryName,
			 E1.CountryCode = E2.CountryCode,
			 E1.DateOfLastChange = getdate()
		  WHEN NOT MATCHED THEN
		  INSERT VALUES( E2.CountryName,getdate(),getdate(), @SystemUser,'', E2.CountryCode,1);

	END TRY
	BEGIN CATCH
		SET @HasError=1
		SELECT @Message =dbo.GetMessageFromLenguajeResorces (0,59)
		DECLARE @ErrorMessage nvarchar(max)
		SELECT @ErrorMessage=ERROR_MESSAGE()
		INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('DTOne.st_SaveCountries',Getdate(),@ErrorMessage)
	END CATCH
END