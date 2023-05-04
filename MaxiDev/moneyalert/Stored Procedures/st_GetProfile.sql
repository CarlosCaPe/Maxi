CREATE PROCEDURE [MoneyAlert].[st_GetProfile]
(
@IdPerson varchar(max),
@IdPersonRole int,
@VIPCard nvarchar(max) OUT,
@Photo nvarchar(max) out,
@PersonName nvarchar(MAX) OUT,
@HasError bit out
)
AS
SET NOCOUNT ON
BEGIN TRY

	SET @HasError=0

	IF @IdPersonRole=1
	BEGIN

		SELECT @PersonName=A.Name ,@Photo=A.Photo,@VIPCard=Isnull(c.CardNumber,'') FROM MoneyAlert.CustomerMobile A
			LEFT JOIN MoneyAlert.Customer B ON (A.IdCustomerMobile=B.IdCustomerMobile)
			LEFT JOIN dbo.CardVIP C ON (B.IdCustomer=C.IdCustomer AND C.IdGenericStatus=1)
		WHERE A.IdCustomerMobile=@IdPerson 

	END
	
	IF @IdPersonRole=2
	BEGIN


		SELECT @PersonName=A.Name ,@Photo=A.Photo,@VIPCard='' 
		FROM MoneyAlert.BeneficiaryMobile A
		WHERE A.IdBeneficiaryMobile=@IdPerson 

		
	END

	   
END TRY
BEGIN CATCH
	SET @HasError=1
	INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
	VALUES (ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH








