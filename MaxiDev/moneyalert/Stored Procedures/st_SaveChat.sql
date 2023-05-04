
CREATE PROCEDURE [MoneyAlert].[st_SaveChat]
(
@IdChat varchar(max),
@IdPersonRole int,
@ChatMessage nvarchar(max),
@Token nvarchar(max) OUT,
@IdPhoneType INT OUT,
@Photo nvarchar(max) out,
@PersonName nvarchar(MAX) OUT,
@HasError bit out
)
AS
SET NOCOUNT ON
BEGIN TRY

	SET @HasError=0

	IF @IdPersonRole=2
	BEGIN

		SELECT @PersonName=B.Name ,@Photo=B.Photo FROM MoneyAlert.Chat A
		JOIN MoneyAlert.BeneficiaryMobile B ON (A.IdBeneficiaryMobile=B.IdBeneficiaryMobile)
		WHERE IdChat=@IdChat

		SELECT @Token=B.Token,@IdPhoneType=IdPhoneType FROM MoneyAlert.Chat A
		JOIN MoneyAlert.CustomerMobile B ON (A.IdCustomerMobile=B.IdCustomerMobile)
		WHERE IdChat=@IdChat
	END
	
	IF @IdPersonRole=1
	BEGIN
		
		SELECT @PersonName=B.Name,@Photo=B.Photo FROM MoneyAlert.Chat A
		JOIN MoneyAlert.CustomerMobile B ON (A.IdCustomerMobile=B.IdCustomerMobile)
		WHERE IdChat=@IdChat

		SELECT @Token=B.Token,@IdPhoneType=IdPhoneType FROM MoneyAlert.Chat A
		JOIN MoneyAlert.BeneficiaryMobile B ON (A.IdBeneficiaryMobile=B.IdBeneficiaryMobile)
		WHERE IdChat=@IdChat
	END

	
	INSERT INTO MoneyAlert.ChatDetail (IdChat,IdPersonRole,ChatMessage,EnteredDate,ChatMessageStatusId) values (@IdChat,@IdPersonRole,@ChatMessage,GETDATE(),1)


       
END TRY
BEGIN CATCH
	SET @HasError=1
	INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
	VALUES (ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH








