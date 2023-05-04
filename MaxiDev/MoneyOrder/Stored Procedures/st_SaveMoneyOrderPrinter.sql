CREATE PROCEDURE MoneyOrder.st_SaveMoneyOrderPrinter
(
	@Identifier				NVARCHAR(200),
	@MoneyOrderPrinter		VARCHAR(200),

	@EnterByIdUser			INT,
	@IdLanguage				INT
)
AS
BEGIN
	DECLARE @MSG_ERROR NVARCHAR(500)

	BEGIN TRY
		UPDATE PcIdentifier SET
			MoneyOrderPrinter = @MoneyOrderPrinter
		WHERE Identifier = @Identifier

		SELECT 
			1 Success,
			dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage,'GenericOkSave') [Message]
	END TRY
	BEGIN CATCH
		IF(ISNULL(@MSG_ERROR, '') = '')
			SET @MSG_ERROR = ERROR_MESSAGE();

		SELECT 
			0 Success,
			dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage,'GenericErrorSave') [Message]

		INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) 
		VALUES(ERROR_PROCEDURE() ,GETDATE(), @MSG_ERROR);
	END CATCH
END