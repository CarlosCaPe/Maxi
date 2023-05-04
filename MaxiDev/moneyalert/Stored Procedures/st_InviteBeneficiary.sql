
CREATE PROCEDURE [MoneyAlert].[st_InviteBeneficiary]
(
@IdTransfer INT,
@CountryCode VARCHAR(MAX),
@PhoneNumber VARCHAR(MAX),
@Message VARCHAR(MAX) OUTPUT,
@PersonName VARCHAR(MAX) OUTPUT,
@Photo VARCHAR(MAX) OUTPUT,
@MAXIIdChat INT OUTPUT,
@HasError BIT OUTPUT
)
AS
SET NOCOUNT ON
BEGIN TRY

	SET @HasError=0
	

	DECLARE @IdBeneficiary INT,@IdBeneficiaryMobile INT,@IdCustomer INT,@IdCustomerMobile INT, @Name NVARCHAR(MAX),@IdChat INT

	SELECT @IdBeneficiary=A.IdBeneficiary,@IdCustomer=A.IdCustomer,@Name=B.Name+' '+B.FirstLastName  FROM Transfer A
	JOIN dbo.Beneficiary B on (A.IdBeneficiary=B.IdBeneficiary)
	WHERE IdTransfer =@IdTransfer

	IF @IdBeneficiary IS NULL 
	BEGIN
		SELECT @IdBeneficiary=IdBeneficiary,@IdCustomer=IdCustomer ,@Name=BeneficiaryName+' '+BeneficiaryFirstLastName FROM TransferClosed WHERE IdTransferClosed =@IdTransfer
	END

	SELECT @IdCustomerMobile=IdCustomerMobile FROM MoneyAlert.Customer WHERE IdCustomer=@IdCustomer

	IF @IdBeneficiary IS NOT NULL
	BEGIN

		IF NOT EXISTS (SELECT 1 FROM  [MoneyAlert].[BeneficiaryMobile] Where PhoneNumber=@PhoneNumber AND CountryCode=@CountryCode)
		BEGIN
		  SELECT @Name= Name+' '+FirstLastName  FROM dbo.Beneficiary WHERE IdBeneficiary=@IdBeneficiary
		  INSERT INTO [MoneyAlert].[BeneficiaryMobile](
			   [CountryCode]
			  ,[PhoneNumber]
			  ,[Name]
			  ,[IsOnline]
			  ,[EnteredDate]
			  ,[DateOfLastChange]
			   )
			   VALUES
			   (
			   @CountryCode,
			   @PhoneNumber,
			   @Name,
			   0,
			   GETDATE(),
			   GETDATE()
			   )
		

		    SET @IdBeneficiaryMobile=SCOPE_IDENTITY()
			INSERT INTO MoneyAlert.Beneficiary(IdBeneficiary,IdBeneficiaryMobile,EnteredDate,DateOfLastChange) VALUES
			(@IdBeneficiary,@IdBeneficiaryMobile,GETDATE(),GETDATE())

		   INSERT INTO MoneyAlert.Chat (IdBeneficiaryMobile,IdCustomerMobile,EnteredDate,DateOfLastChange)VALUES(@IdBeneficiaryMobile,@IdCustomerMobile,GETDATE(),Getdate())

		   
		   SELECT @IdChat=SCOPE_IDENTITY() 
	       INSERT INTO MoneyAlert.ChatDetail (IdChat,IdPersonRole,ChatMessage,EnteredDate,ChatMessageStatusId)
		   VALUES (@IdChat,1,'Welcome /  Bienvenido',Getdate(),2)


		END
		ELSE
		BEGIN
				SELECT @IdBeneficiaryMobile=IdBeneficiaryMobile FROM MoneyAlert.BeneficiaryMobile WHERE PhoneNumber=@PhoneNumber AND CountryCode=@CountryCode
				IF NOT EXISTS(SELECT 1 FROM  [MoneyAlert].[Beneficiary] WHERE IdBeneficiary=@IdBeneficiary AND IdBeneficiaryMobile=@IdBeneficiaryMobile)
			BEGIN
				INSERT INTO MoneyAlert.Beneficiary(IdBeneficiary,IdBeneficiaryMobile,EnteredDate,DateOfLastChange) VALUES
				(@IdBeneficiary,@IdBeneficiaryMobile,GETDATE(),GETDATE())
			END



			IF NOT EXISTS (SELECT 1 FROM MoneyAlert.Chat WHERE IdBeneficiaryMobile=@IdBeneficiaryMobile and IdCustomerMobile=@IdCustomerMobile)
			BEGIN
				   INSERT INTO MoneyAlert.Chat (IdBeneficiaryMobile,IdCustomerMobile,EnteredDate,DateOfLastChange)VALUES(@IdBeneficiaryMobile,@IdCustomerMobile,GETDATE(),Getdate())

				   SELECT @IdChat=SCOPE_IDENTITY() 
				   INSERT INTO MoneyAlert.ChatDetail (IdChat,IdPersonRole,ChatMessage,EnteredDate,ChatMessageStatusId)
				   VALUES (@IdChat,1,'Welcome /  Bienvenido',Getdate(),2)
			END


		END
			
		
				   --------------- MENSAJE DE MAXI AL CUSTOMER  -----------------------------------------------------------

						SELECT @Message='You have sent a successful invitation to '+@Name+' to Cel number '+CONVERT(VARCHAR,@CountryCode)+' '+CONVERT(VARCHAR,@PhoneNumber)+
											'/Has enviado una invitación exitosa a '+@Name+' al número Celular '+CONVERT(VARCHAR,@CountryCode)+' '+CONVERT(VARCHAR,@PhoneNumber)

						SELECT @PersonName=Name,@Photo=Photo FROM MoneyAlert.BeneficiaryMobile WHERE IdBeneficiaryMobile=1
		
						SELECT @MAXIIdChat=IdChat FROM MoneyAlert.Chat WHERE IdCustomerMobile=@IdCustomerMobile AND IdBeneficiaryMobile=1

						INSERT INTO MoneyAlert.ChatDetail (IdChat,IdPersonRole,ChatMessage,EnteredDate,ChatMessageStatusId)VALUES(@MAXIIdChat,2,@Message,GETDATE(),1) 


		
	END

       
END TRY
BEGIN CATCH
	SET @HasError=1
	INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
	VALUES (ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH






