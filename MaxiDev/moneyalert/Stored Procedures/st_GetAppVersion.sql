

CREATE PROCEDURE [MoneyAlert].[st_GetAppVersion]
(
@IdPhoneType Int, 
@AppVersion nvarchar(max) OUTPUT,
@HasError bit out
)
AS
SET NOCOUNT ON
BEGIN TRY

	SET @HasError=0

		SELECT  @AppVersion=AppVersion  FROM MoneyAlert.PhoneType  WHERE IdPhoneType=@IdPhoneType
			
       
END TRY
BEGIN CATCH
	SET @HasError=1
	INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
	VALUES (ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH









