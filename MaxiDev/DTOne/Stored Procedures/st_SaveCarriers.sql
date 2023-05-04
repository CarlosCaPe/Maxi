-- =============================================
-- Author:		Oscar Cardenas
-- Create date: 10/02/2023
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [DTOne].[st_SaveCarriers]
		@Carriers AS [DTOne].[CarrierType] READONLY,
		@HasError AS bit out,
		@Message AS nvarchar(max) out
AS
BEGIN
	BEGIN TRY
	DECLARE @SystemUser int
	SELECT @SystemUser=[dbo].[GetGlobalAttributeByName] ( 'SystemUserID' ) 


		  MERGE INTO [DTOne].[Carrier] E1
		  USING @Carriers E2
		  ON E1.IdCarrierDTO=E2.IdCarrierDTO
		  WHEN MATCHED THEN
		  UPDATE SET 
			 E1.CarrierName = E2.CarrierName,
			 E1.DateOfLastChange = getdate()
		  WHEN NOT MATCHED THEN
		  INSERT VALUES( (SELECT TOP 1 [IdCountry] FROM [DTOne].[Country] C WHERE C.[CountryCode] = E2.[CountryCode]), E2.CarrierName,getdate(),getdate(), @SystemUser,E2.IdCarrierDTO, 1);

	END TRY
	BEGIN CATCH
		SET @HasError=1
		SELECT @Message =dbo.GetMessageFromLenguajeResorces (0,59)
		DECLARE @ErrorMessage nvarchar(max)
		SELECT @ErrorMessage=ERROR_MESSAGE()
		INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('DTOne.st_SaveCarriers',Getdate(),@ErrorMessage)
	END CATCH
END