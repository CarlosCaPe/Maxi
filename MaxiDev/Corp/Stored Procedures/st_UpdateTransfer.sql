CREATE PROCEDURE [Corp].[st_UpdateTransfer]
	-- Add the parameters for the stored procedure here
    @TransferId INT,
    @Purpose NVARCHAR(MAX),
    @Relationship NVARCHAR(MAX),
    @MoneySource NVARCHAR(MAX),
    @CustomerAddress NVARCHAR(MAX),
    @CustomerCity NVARCHAR(MAX),
    @CustomerState NVARCHAR(MAX),
    @CustomerZipCode NVARCHAR(MAX),
    @CustomerCountry NVARCHAR(MAX),
    @CustomerPhoneNumber NVARCHAR(MAX),
    @CustomerCellularNumber NVARCHAR(MAX),
    @CustomerIdCustomerIdentificationType INT = NULL,
    @CustomerIdentificationIdCountry INT = NULL,
    @CustomerIdentificationIdState INT = NULL,
    @CustomerExpirationIdentification DATETIME = NULL,
    @CustomerIdentificationNumber NVARCHAR(MAX),
    @CustomerBornDate DATETIME = NULL,
    @CustomerSSNNumber NVARCHAR(MAX),
    @CustomerOccupation NVARCHAR(MAX),
	@CustomerIdOccupation int = 0, /*M00207*/
	@CustomerIdSubcategoryOccupation int = 0,/*M00207*/
	@CustomerSubcategoryOccupationOther nvarchar(max) ='',/*M00207*/ 
    @BeneficiaryName NVARCHAR(MAX),
    @BeneficiaryBornDate DATETIME = NULL,
    @BeneficiarySecondLastName NVARCHAR(MAX),
    @BeneficiaryFirstLastName NVARCHAR(MAX),
    @BeneficiaryAddress NVARCHAR(MAX),
    @BeneficiaryCity NVARCHAR(MAX),
    @BeneficiarySSNumber NVARCHAR(MAX),
    @BeneficiaryCellularNumber NVARCHAR(MAX),
    @BeneficiaryState NVARCHAR(MAX),
    @BeneficiaryZipcode NVARCHAR(MAX),
    @BeneficiaryCountry NVARCHAR(MAX),
    @BeneficiaryPhoneNumber NVARCHAR(MAX),
    @BeneficiaryOccupation NVARCHAR(MAX) = NULL,
    @BeneficiaryNote NVARCHAR(MAX),
    @IdBeneficiaryIdentificationType INT = NULL,
    @BeneficiaryIdentificationNumber NVARCHAR(MAX) = NULL,
    
    @CustomerTypeTAXID INT,
    @CustomerHasTAXID BIT,
    
    @EnterByIdUser INT,
    @IsSaveCustomer BIT = NULL,
    @IsSpanishLanguage BIT = 0,
    @HasError BIT = 0 OUTPUT,
    @Message VARCHAR(max) = '' OUTPUT,
    @CustomerBirthCountryId INT = NULL,
    @BeneficiaryBirthCountryId INT = NULL

AS
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="2017/10/30" Author="snevarez">S44::REQ. MA.025 : Add detail for Other Occupations</log>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
<log Date="2020/10/04" Author="esalazar" Name="Occupations">-- CR M00207	</log>
</ChangeLog>
********************************************************************/
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @Date DATETIME = GETDATE()

	IF EXISTS (SELECT TOP 1 1 FROM [dbo].[TransferClosed] WITH (NOLOCK) WHERE [IdTransferClosed] = @TransferId)
	BEGIN
		SELECT
			@HasError = 1
			, @Message = 'Transfer is not allowed to edit'
		RETURN
	END

	DECLARE @CustomerId INT

	IF @CustomerIdCustomerIdentificationType = 0 SET @CustomerIdCustomerIdentificationType = NULL
	IF @CustomerIdentificationIdCountry = 0 SET @CustomerIdentificationIdCountry = NULL
	IF @CustomerIdentificationIdState = 0 SET @CustomerIdentificationIdState = NULL
	IF @CustomerExpirationIdentification = 0 SET @CustomerExpirationIdentification = NULL
	IF @IdBeneficiaryIdentificationType = 0 SET @IdBeneficiaryIdentificationType = NULL
	IF @CustomerBirthCountryId = 0 SET @CustomerBirthCountryId = NULL
	IF @BeneficiaryBirthCountryId = 0 SET @BeneficiaryBirthCountryId = NULL
	
    /*S44:REQ. MA.025 - BEGIN*/
	/*
    DECLARE @CustomerOccupationDetail NVARCHAR(MAX);
    IF(UPPER(@CustomerOccupation) LIKE 'OTHER%')
    BEGIN
	   SET @CustomerOccupationDetail = RTRIM(ltrim(SUBSTRING(@CustomerOccupation,6,LEN(@CustomerOccupation))));
	   SET @CustomerOccupation = RTRIM(ltrim(SUBSTRING(@CustomerOccupation,0,6)));
    END
    ELSE
    BEGIN
	   IF(UPPER(@CustomerOccupation) LIKE 'OTRA%')
	   BEGIN
		  SET @CustomerOccupationDetail = RTRIM(ltrim(SUBSTRING(@CustomerOccupation,5,LEN(@CustomerOccupation))));
		  SET @CustomerOccupation = RTRIM(ltrim(SUBSTRING(@CustomerOccupation,0,5)));
	   END
	   ELSE
	   BEGIN
		  IF(@IsSpanishLanguage = 0)
		  BEGIN
			 IF NOT EXISTS(SELECT 1 FROM DictionaryOccupation with(nolock) WHERE Name = UPPER(rtrim(LTRIM(@CustomerOccupation))))
			 BEGIN
				SET @CustomerOccupationDetail = @CustomerOccupation;
				SET @CustomerOccupation = '--OTHER--';
			 END
		  END
		  ELSE
		  BEGIN
			 IF NOT EXISTS(SELECT 1 FROM DictionaryOccupation with(nolock) WHERE NameEs = UPPER(rtrim(LTRIM(@CustomerOccupation))))
			 BEGIN
				SET @CustomerOccupationDetail = @CustomerOccupation;
				SET @CustomerOccupation = '--OTRA--';
			 END
		  END
	   END
    END
	-- CR M00207
	*/
    /*S44:REQ. MA.025 - END*/

	UPDATE [dbo].[Transfer] SET
		[Purpose] = @Purpose
		, [Relationship] = @Relationship
		, [MoneySource] = @MoneySource
		, [CustomerAddress] = @CustomerAddress
		, [CustomerCity] = @CustomerCity
		, [CustomerState] = @CustomerState
		, [CustomerZipcode] = @CustomerZipCode
		, [CustomerCountry] = @CustomerCountry
		, [CustomerPhoneNumber] = @CustomerPhoneNumber
		, [CustomerCelullarNumber] = @CustomerCellularNumber
		, [CustomerIdCustomerIdentificationType] = @CustomerIdCustomerIdentificationType
		, [CustomerIdentificationIdState] = @CustomerIdentificationIdState
		, [CustomerIdentificationIdCountry] = @CustomerIdentificationIdCountry
		, [CustomerExpirationIdentification] = @CustomerExpirationIdentification
		, [CustomerIdentificationNumber] = @CustomerIdentificationNumber
		, [CustomerBornDate] = @CustomerBornDate
		, [CustomerSSNumber] = @CustomerSSNNumber

		, [CustomerOccupation] = @CustomerOccupation
		, [CustomerOccupationDetail] = ''  /*@CustomerOccupationDetail S44:REQ. MA.025*/

		,CustomerIdOccupation =@CustomerIdOccupation
		,CustomerIdSubOccupation=@CustomerIdSubcategoryOccupation
		,CustomerSubOccupationOther=@CustomerSubcategoryOccupationOther

		, [BeneficiaryName] = @BeneficiaryName
		, [BeneficiaryFirstLastName] = @BeneficiaryFirstLastName
		, [BeneficiarySecondLastName] = @BeneficiarySecondLastName
		, [BeneficiaryBornDate] = @BeneficiaryBornDate
		, [BeneficiaryAddress] = @BeneficiaryAddress
		, [BeneficiaryCity] = @BeneficiaryCity
		, [BeneficiarySSNumber] = @BeneficiarySSNumber
		, [BeneficiaryCelularNumber] = @BeneficiaryCellularNumber
		, [BeneficiaryState] = @BeneficiaryState
		, [BeneficiaryZipcode] = @BeneficiaryZipcode
		, [BeneficiaryCountry] = @BeneficiaryCountry
		, [BeneficiaryPhoneNumber] = @BeneficiaryPhoneNumber
		, [BeneficiaryOccupation] = @BeneficiaryOccupation
		, [BeneficiaryNote] = @BeneficiaryNote
		, [IdBeneficiaryIdentificationType] = @IdBeneficiaryIdentificationType
		, [BeneficiaryIdentificationNumber] = @BeneficiaryIdentificationNumber
		, [DateOfLastChange] = @Date
		, @CustomerId = [IdCustomer] -- Select Customer Id
		, [CustomerIdCountryOfBirth] = @CustomerBirthCountryId
		, [BeneficiaryIdCountryOfBirth] = @BeneficiaryBirthCountryId
	WHERE [IdTransfer] = @TransferId;

	IF @@ROWCOUNT = 0
	BEGIN
		SELECT
			@HasError = 1
			, @Message = 'No Exists Transfer'
		RETURN
	END

	EXEC [Corp].[st_UpdateCustomerInformation]
		@IdCustomer = @CustomerId
		, @Address = @CustomerAddress
		, @EnterByIdUser = @EnterByIdUser
		, @IdCustomerIdentificationType = @CustomerIdCustomerIdentificationType
		, @SSNumber = @CustomerSSNNumber
		, @BornDate = @CustomerBornDate

		, @Occupation = @CustomerOccupation
		, @OccupationDetail = '' /* @CustomerOccupationDetail S44:REQ. MA.025*/

		,@IdOccupation =@CustomerIdOccupation /*M00207*/
		,@IdSubcategoryOccupation = @CustomerIdSubcategoryOccupation/*M00207*/
		,@SubcategoryOccupationOther = @CustomerSubcategoryOccupationOther/*M00207*/ 

		, @ExpirationIdentification = @CustomerExpirationIdentification
		, @IdentificationNumber = @CustomerIdentificationNumber
		, @CelullarNumber = ''
		, @City = ''
		, @Country = ''
		, @DateOfLastChange = @Date
		, @Name = ''
		, @IdAgentCreatedBy = 0
		, @IdCarrier = 0
		, @IdGenericStatus = 0
		, @LastName = ''
		, @PhoneNumber = ''
		, @PhysicalIdCopy = 0
		, @SecondLastName = ''
		, @State = ''
		, @ZipCode = ''
		, @Action = 2
		, @IsSaveCustomer = @IsSaveCustomer
		, @HasError = @HasError OUTPUT
		, @Message = @Message OUTPUT
		, @CustomerIdentificationIdCountry = @CustomerIdentificationIdCountry
		, @CustomerIdentificationIdState = @CustomerIdentificationIdState
		, @CustomerBirthCountryId = @CustomerBirthCountryId
		, @CustomerTypeTAXIDc = @CustomerTypeTAXID
    	, @CustomerHasTAXIDc = @CustomerHasTAXID;

	IF @HasError = 1
		RETURN

	SELECT @HasError = 0, @Message = 'Transfer information has been successfully saved';

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage nvarchar(max)
	SELECT @ErrorMessage=ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('[Corp].[st_UpdateTransfer]', GETDATE(), @ErrorMessage);
	SELECT @HasError=1, @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33)
END CATCH

