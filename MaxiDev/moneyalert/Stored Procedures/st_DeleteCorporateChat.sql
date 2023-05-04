


CREATE PROCEDURE [MoneyAlert].[st_DeleteCorporateChat]
(
@IdChat INT,
@HasError BIT OUTPUT
)
AS
SET NOCOUNT ON
BEGIN TRY

	SET @HasError=0

	DELETE MoneyAlert.CorporateChat WHERE IdChat=@IdChat
       
END TRY
BEGIN CATCH
	SET @HasError=1
	INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
	VALUES (ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH




