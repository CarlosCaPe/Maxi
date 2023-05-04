

  CREATE PROCEDURE [MoneyAlert].[st_InviteCustomer]
  (
  @IdCustomer INT,
  @CountryCode NVARCHAR(MAX),
  @CelNumber NVARCHAR(MAX),
  @SecureCode NVARCHAR(MAX) OUTPUT,
  @HasError BIT OUTPUT
  )
  AS
SET NOCOUNT ON
BEGIN TRY

	SET @HasError=0
	SELECT @SecureCode=RIGHT(CONVERT(NVARCHAR,@IdCustomer),4)
	DECLARE @PhoneNumber NVARCHAR(MAX), @Name NVARCHAR(MAX),@IdCustomerMobile INT

	IF NOT EXISTS ( SELECT 1 FROM  [MoneyAlert].[CustomerMobile] (NOLOCK) WHERE PhoneNumber=@CelNumber AND CountryCode=@CountryCode)
	BEGIN
		
		EXEC [MoneyAlert].[st_DeleteCustomerConfiguration] @IdCustomer -- Remove the client configuration for any number
		
		SELECT @Name= Name+' '+FirstLastName  FROM [dbo].[Customer] (NOLOCK) WHERE IdCustomer=@IdCustomer
		INSERT INTO [MoneyAlert].[CustomerMobile](
			[CountryCode]
			,[PhoneNumber]
			,[Name]
			,[IsOnline]
			,[EnteredDate]
			,[DateOfLastChange]
			,[SecureCode]
			)
			VALUES
			(
			@CountryCode,
			@CelNumber,
			@Name,
			0,
			GETDATE(),
			GETDATE(),
			@SecureCode
			)

		SET @IdCustomerMobile=SCOPE_IDENTITY()
		INSERT INTO [MoneyAlert].[Customer] (IdCustomer,IdCustomerMobile,EnteredDate,DateOfLastChange) VALUES (@IdCustomer,@IdCustomerMobile,GETDATE(),GETDATE())

		INSERT INTO [MoneyAlert].[Chat] (IdBeneficiaryMobile,IdCustomerMobile,EnteredDate,DateOfLastChange)VALUES(1,@IdCustomerMobile,GETDATE(),GETDATE())

		DECLARE @IdChat INT
		SELECT @IdChat=SCOPE_IDENTITY() 
	 
		INSERT INTO [MoneyAlert].[ChatDetail] (IdChat,IdPersonRole,ChatMessage,EnteredDate,ChatMessageStatusId) VALUES (@IdChat,1,'Welcome /  Bienvenido',GETDATE(),2)

	END
	ELSE
	BEGIN
		SELECT @IdCustomerMobile=IdCustomerMobile FROM [MoneyAlert].[CustomerMobile] (NOLOCK) WHERE PhoneNumber=@CelNumber AND CountryCode=@CountryCode
		IF NOT EXISTS(SELECT 1 FROM  [MoneyAlert].[Customer] (NOLOCK) WHERE IdCustomer=@IdCustomer AND IdCustomerMobile=@IdCustomerMobile)
			BEGIN
				INSERT INTO [MoneyAlert].[Customer] (IdCustomer,IdCustomerMobile,EnteredDate,DateOfLastChange) VALUES
				(@IdCustomer,@IdCustomerMobile,GETDATE(),GETDATE())
			END
    END      
END TRY
BEGIN CATCH
	SET @HasError=1
	INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
	VALUES (ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH







