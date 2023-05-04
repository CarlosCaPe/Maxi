
CREATE PROCEDURE [MoneyAlert].[st_SavePhoto]
(
@IdPerson INT,
@IdPersonRole INT,
@Photo nvarchar(max),
@HasError bit out
)
AS
SET NOCOUNT ON
BEGIN TRY
	
	SET @HasError=0

	IF @IdPersonRole=1
	BEGIN
		UPDATE MoneyAlert.CustomerMobile SET Photo=@Photo WHERE IdCustomerMobile=@IdPerson
	END

	IF @IdPersonRole=2
	BEGIN
		UPDATE MoneyAlert.BeneficiaryMobile SET Photo=@Photo WHERE IdBeneficiaryMobile=@IdPerson
	END

	    
END TRY
BEGIN CATCH
	SET @HasError=1
	INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
	VALUES (ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH









