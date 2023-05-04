

CREATE PROCEDURE [moneyalert].[st_InsertCorporateChat]
(
@IdUser INT,
@IdChat INT,
@HasError BIT OUTPUT
)
AS
SET NOCOUNT ON
BEGIN TRY

	SET @HasError=0

	IF NOT EXISTS (SELECT 1 FROM MoneyAlert.CorporateChat WHERE IdChat=@IdChat)
	BEGIN
		INSERT INTO MoneyAlert.CorporateChat (IdUser,IdChat,EnteredDate)values(@IdUser,@IdChat,getdate())	
	END

	exec MoneyAlert.st_SaveStoreProcedureUsage 'MoneyAlert.st_InsertCorporateChat',@IdUser   
       
END TRY
BEGIN CATCH
	SET @HasError=1
	INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
	VALUES (ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH



