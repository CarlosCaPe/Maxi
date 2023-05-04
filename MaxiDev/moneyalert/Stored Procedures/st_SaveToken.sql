

CREATE PROCEDURE [MoneyAlert].[st_SaveToken]
(
@CountryCode varchar(max),
@PhoneNumber varchar(max),
@Token nvarchar(max),
@IdPhoneType INT,
@Language int, 
@SecureCode nvarchar(max) OUT,
@PersonName nvarchar(MAX) OUT,
@IdPerson Int Out, 
@IdPersonRole int OUT,
@MaxiMessage NVARCHAR(MAX) OUT,
@MaxiPersonName NVARCHAR(MAX) OUT,
@MaxiPhoto nvarchar(max) output,
@MaxiIdChat int output,
@MaxiToken NVARCHAR(MAX) OUTPUT,
@MaxiIdPhoneType Int OUTPUT,
@HasError bit out,  
@ResultMessage nvarchar(max) out  
)
AS
SET NOCOUNT ON
BEGIN TRY

	SET @HasError=0

	DECLARE @IdCustomerMobile INT

	SELECT @IdPerson=A.IdCustomerMobile,@IdPersonRole=1,@SecureCode=A.SecureCode,@PersonName=A.Name FROM MoneyAlert.CustomerMobile A
	WHERE A.CountryCode=@CountryCode AND A.PhoneNumber=@PhoneNumber

	IF @IdPerson IS NULL
	BEGIN
			SELECT @IdPerson=A.IdBeneficiaryMobile,@IdPersonRole=2, @PersonName=A.Name  FROM MoneyAlert.BeneficiaryMobile A 
			WHERE A.CountryCode=@CountryCode AND A.PhoneNumber=@PhoneNumber

			

	END

	IF @IdPerson IS NOT NULL AND @IdPersonRole=1
	BEGIN
		UPDATE MoneyAlert.CustomerMobile SET Token=@Token,DateOfLastChange=Getdate(),IdPhoneType=@IdPhoneType WHERE IdCustomerMobile=@IdPerson
	END
	
	IF @IdPerson IS NOT NULL AND @IdPersonRole=2
	BEGIN
		UPDATE MoneyAlert.BeneficiaryMobile SET Token=@Token,DateOfLastChange=Getdate(),IdPhoneType=@IdPhoneType WHERE IdBeneficiaryMobile=@IdPerson


		SELECT @MaxiMessage=@PersonName+'  Already Accepted invitation to Maxi Money Alert, now you can chat with your Beneficiary' +
									'/ '+@PersonName+' Ya ha aceptado la invitación a Maxi Money Alert, ahora puedes chatear con tu Beneficiario '

			SELECT @MaxiPersonName=Name,@MaxiPhoto=Photo FROM MoneyAlert.BeneficiaryMobile WHERE IdBeneficiaryMobile=1
	
			SELECT @IdCustomerMobile=IdCustomerMobile FROM MoneyAlert.Chat WHERE IdBeneficiaryMobile=@IdPerson 
			SELECT @MAXIIdChat=IdChat FROM MoneyAlert.Chat WHERE IdBeneficiaryMobile=1 AND IdCustomerMobile=@IdCustomerMobile

			INSERT INTO MoneyAlert.ChatDetail (IdChat,IdPersonRole,ChatMessage,EnteredDate,ChatMessageStatusId) VALUES (@MAXIIdChat,2,@MaxiMessage,Getdate(),2)
	
			SELECT @MaxiIdPhoneType=IdPhoneType,@MaxiToken=Token FROM MoneyAlert.CustomerMobile WHERE IdCustomerMobile=@IdCustomerMobile
	END

	IF @IdPerson IS NULL
		BEGIN
			SELECT @ResultMessage= [dbo].[GetMessageFromMultiLenguajeResorces] (@Language,'MoneyAlert1')		
			SET @HasError=1	
		END

       
END TRY
BEGIN CATCH
	SET @HasError=1
	INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
	VALUES (ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH




