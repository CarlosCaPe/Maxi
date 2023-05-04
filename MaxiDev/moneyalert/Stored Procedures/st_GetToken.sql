

CREATE PROCEDURE [MoneyAlert].[st_GetToken]
(
@IdChat varchar(max),
@IdPersonRole int,
@Token nvarchar(max) OUT,
@IdPhoneType INT OUT,
@PersonName nvarchar(max) OUT,
@HasError bit out
)
AS
SET NOCOUNT ON
BEGIN TRY

	SET @HasError=0

	IF @IdPersonRole=2
	BEGIN
		SELECT @Token=B.Token,@PersonName=B.Name,@IdPhoneType=IdPhoneType FROM MoneyAlert.Chat A
		JOIN MoneyAlert.CustomerMobile B ON (A.IdCustomerMobile=B.IdCustomerMobile)
		WHERE IdChat=@IdChat
	END
	
	IF @IdPersonRole=1
	BEGIN
		SELECT @Token=B.Token,@PersonName=B.Name,@IdPhoneType=IdPhoneType FROM MoneyAlert.Chat A
		JOIN MoneyAlert.BeneficiaryMobile B ON (A.IdBeneficiaryMobile=B.IdBeneficiaryMobile)
		WHERE IdChat=@IdChat
	END

	

       
END TRY
BEGIN CATCH
	SET @HasError=1
	INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
	VALUES (ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH








