CREATE PROCEDURE [Corp].[st_UpdateCustomerInformation]
(
    @IdCustomer INT = 0,
    @Address NVARCHAR(MAX),
    @EnterByIdUser INT,
    @IdCustomerIdentificationType INT,
    @SSNumber NVARCHAR(MAX),
    @BornDate DATETIME,  

    @Occupation NVARCHAR(MAX),
    @OccupationDetail NVARCHAR(MAX),	   /*S44:REQ. MA.025*/

	@IdOccupation int = 0, /*M00207*/
	@IdSubcategoryOccupation int = 0,/*M00207*/
	@SubcategoryOccupationOther nvarchar(max) ='',/*M00207*/ 

    @ExpirationIdentification DATETIME,
    @IdentificationNumber NVARCHAR(MAX),
    @CelullarNumber  NVARCHAR(15),
    @City  NVARCHAR(MAX),
    @Country  NVARCHAR(MAX),
    @DateOfLastChange DATETIME,
    @Name  NVARCHAR(40),
    @IdAgentCreatedBy INT,
    @IdCarrier INT = 0,
    @IdGenericStatus INT,
    @LastName  NVARCHAR(40),
    @PhoneNumber NVARCHAR(15),
    @PhysicalIdCopy INT,
    @SecondLastName NVARCHAR(40),
    @State NVARCHAR(40),
    @ZipCode NVARCHAR(40),
    @Action INT,
    @IsSaveCustomer BIT = NULL,
    @HasError BIT = 0 OUT,
    @Message VARCHAR(MAX) = '' OUT,
    @IdCustomerOut INT = 0 OUT,
	@IdElasticCustomer varchar(max) = '' OUT,
    @CustomerIdentificationIdCountry INT = NULL,
    @CustomerIdentificationIdState INT = NULL,
    @CustomerBirthCountryId INT = NULL,
    @CustomerTypeTAXIDc INT,
    @CustomerHasTAXIDc BIT
)
AS
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="2017/10/30" Author="snevarez">S44::REQ. MA.025 : Add detail for Other Occupations</log>
<log Date="2018/01/18" Author="azavala">Optimizacion Agente</log>
<log Date="2020/10/04" Author="esalazar" Name="Occupations">-- CR M00207	</log>
</ChangeLog>
********************************************************************/
BEGIN TRY

	IF @IdCustomerIdentificationType = 0 SET @IdCustomerIdentificationType = NULL
	IF @CustomerIdentificationIdCountry = 0 SET @CustomerIdentificationIdCountry = NULL
	IF @CustomerIdentificationIdState = 0 SET @CustomerIdentificationIdState = NULL
	IF @CustomerBirthCountryId = 0 SET @CustomerBirthCountryId = NULL

	DECLARE @Date DATETIME = GETDATE()
	DECLARE @tableUploads as table(
		IdUpload int,
		CreationDate datetime
	)
	DECLARE @IdUploadf int = 0

	IF @IdCustomer = 0 AND @Action = 1 -- Only for request from Agent (@Action = 1)
	BEGIN
		INSERT [dbo].[Customer](
			[Address],
			[CelullarNumber],
			[City],
			[Country],
			[DateOfLastChange],
			[EnterByIdUser],
			[ExpirationIdentification],
			[Name],
			[IdAgentCreatedBy],
			[IdCarrier],
			[IdGenericStatus],
			[FirstLastName],
			[Occupation],
			[PhoneNumber],
			[PhysicalIdCopy],
			[SecondLastName],
			[SSNumber],
			[State],
			[ZipCode],
			[IdentificationIdCountry],
			[IdentificationIdState],
			[IdCountryOfBirth],
			[creationdate]
			,[OccupationDetail]	  /*S44:REQ. MA.025*/
			,IdOccupation /*M00207*/
			,IdSubcategoryOccupation /*M00207*/
			,SubcategoryOccupationOther /*M00207*/
			,[IdTypeTax] 
			,[HasAnswerTaxId]
			)
		VALUES(
			@Address,
			@CelullarNumber,
			@City,
			@Country,
			@Date,
			@EnterByIdUser,
			@ExpirationIdentification,
			@Name,
			@IdAgentCreatedBy,
			@IdCarrier,
			@IdGenericStatus,
			@LastName ,
			@Occupation ,
			@PhoneNumber,
			@PhysicalIdCopy,
			@SecondLastName,
			@SSNumber ,
			@State,
			@ZipCode,
			@CustomerIdentificationIdCountry,
			@CustomerIdentificationIdState,
			@CustomerBirthCountryId,
			GETDATE()
			,@OccupationDetail	  /*S44:REQ. MA.025*/
			,@IdOccupation  /*M00207*/
			,@IdSubcategoryOccupation  /*M00207*/
			,@SubcategoryOccupationOther /*M00207*/ 
			,@CustomerTypeTAXIDc
			,@CustomerHasTAXIDc
			)

	  SET @IdCustomerOut = SCOPE_IDENTITY() /*Optimizacion Agente*/
	  SET @IdElasticCustomer = '' /*Optimizacion Agente*/
	  SET @HasError = 0
	END
	ELSE IF @Action = 1 -- From Billpayment solution in Agent
	BEGIN
		IF @IsSaveCustomer = 1
		BEGIN

			EXEC [Corp].[st_SaveCustomerMirror] @IdCustomer
    
			UPDATE [dbo].[Customer] SET
				[Address] = @Address,
				[CelullarNumber] = @CelullarNumber,
				[City] = @City,
				[DateOfLastChange] = @Date,
				[EnterByIdUser] = @EnterByIdUser,
				[ExpirationIdentification] = @ExpirationIdentification,
				[Name] =  @Name,
				[IdCarrier] = @IdCarrier,
				[FirstLastName] = @LastName,
				
				[Occupation] = @Occupation,
				[OccupationDetail] = @OccupationDetail, /*S44:REQ. MA.025*/
				[IdOccupation] = @IdOccupation,/*M00207*/
				[IdSubcategoryOccupation] = @IdSubcategoryOccupation,/*M00207*/
				[SubcategoryOccupationOther] = @SubcategoryOccupationOther,/*M00207*/

				[SecondLastName] = @SecondLastName,
				[SSNumber] = @SSNumber, 
				[State] = @State,
				[ZipCode] = @ZipCode,
				[IdTypeTax] = @CustomerTypeTAXIDc,
				[HasAnswerTaxId] = @CustomerHasTAXIDc
			WHERE [IdCustomer] = @IdCustomer
			
			SET @IdCustomerOut = @IdCustomer /*Optimizacion Agente*/
			SET @IdElasticCustomer = (Select top(1) idElasticCustomer from Customer with (nolock) where IdCustomer = @IdCustomer) /*Optimizacion Agente*/
			SET @HasError = 0
			  
		END
		SET @IdCustomerOut = @IdCustomer
		SET @IdElasticCustomer = (Select top(1) idElasticCustomer from Customer with (nolock) where IdCustomer = @IdCustomer)
		SET @Message = 'Customer Information has been successfully saved'
		SET @HasError = 0
	END
	ELSE IF(@Action = 2) -- From Backoffice solution in Corporate
	BEGIN
		IF @IsSaveCustomer=1
		BEGIN
			EXEC [Corp].[st_SaveCustomerMirror] @IdCustomer
    
			UPDATE [dbo].[Customer] SET
			[Address] = @Address,
			[DateOfLastChange] = @Date,
			[EnterByIdUser] = @EnterByIdUser,
			[IdCustomerIdentificationType] = @IdCustomerIdentificationType,
			[SSNumber] = @SSNumber,
			[BornDate] = @BornDate,

			[Occupation] = @Occupation,
			[OccupationDetail] = @OccupationDetail, /*S44:REQ. MA.025*/

			[IdOccupation] = @IdOccupation,/*M00207*/
			[IdSubcategoryOccupation] = @IdSubcategoryOccupation,/*M00207*/
			[SubcategoryOccupationOther] = @SubcategoryOccupationOther,/*M00207*/


			[ExpirationIdentification] = @ExpirationIdentification,
			[IdentificationNumber] = @IdentificationNumber,
			[IdentificationIdCountry] = @CustomerIdentificationIdCountry,
			[IdentificationIdState] = @CustomerIdentificationIdState,
			[IdCountryOfBirth] = @CustomerBirthCountryId
			WHERE idCustomer = @IdCustomer
			
			SET @IdCustomerOut = @IdCustomer
			SET @IdElasticCustomer = (Select top(1) idElasticCustomer from Customer with (nolock) where IdCustomer = @IdCustomer)
			 
		END
		
		--IF EXISTS(SELECT 1 FROM UPLOADFILES WHERE IdReference = @IdCustomer AND IdDocumentType = @IdCustomerIdentificationType AND Expirationdate >= GETDATE())
		IF ((SELECT count(IdUploadFile) FROM UPLOADFILES WHERE IdReference = @IdCustomer AND IdDocumentType = @IdCustomerIdentificationType AND Expirationdate >= GETDATE()) > 1)
			BEGIN 
				DECLARE @fisrtDate DATETIME
				INSERT INTO @tableUploads SELECT TOP 1 UF.IdUploadFile, CreationDate FROM UPLOADFILES UF LEFT JOIN UploadFilesDetail UFD ON UF.IdUploadFile = UFD.IdUploadFile
				 WHERE IdReference = @IdCustomer 
				   AND IdDocumentType = @IdCustomerIdentificationType  
				   AND 1 = ISNULL(UFD.IdDocumentImageType ,1)
				   AND UF.Expirationdate >= GETDATE()
				 Order By CreationDate DESC

				 SELECT TOP 1 @fisrtDate = CreationDate FROM @tableUploads
				
				INSERT INTO @tableUploads SELECT TOP 1 UFL.IdUploadFile, UFL.CreationDate FROM UPLOADFILES UFL INNER JOIN UploadFilesDetail UFDT ON UFL.IdUploadFile = UFDT.IdUploadFile
				 WHERE IdReference = @IdCustomer 
				   AND IdDocumentType = @IdCustomerIdentificationType 
				   AND IdDocumentImageType = 2
				   AND DATEPART(DAYOFYEAR, CreationDate) = DATEPART(DAYOFYEAR, @fisrtDate) 
				 Order By CreationDate DESC
				
				WHILE EXISTS(SELECT 1 FROM @tableUploads)
					BEGIN 
						SELECT TOP 1  @IdUploadf = IdUpload FROM @tableUploads
						UPDATE UPLOADFILES SET ExpirationDate = @ExpirationIdentification, DateOfBirth = @BornDate WHERE IdUploadFile = @IdUploadf
						IF EXISTS(SELECT 1 FROM UploadFilesDetail WHERE IdUploadFile = @IdUploadf)
							BEGIN 
								UPDATE UploadFilesDetail SET IdCountry = @CustomerIdentificationIdCountry, IdState = @CustomerIdentificationIdState  WHERE IdUploadFile = @IdUploadf 
							END
						ELSE
							BEGIN
								INSERT INTO UploadFilesDetail SELECT @IdUploadf, 1, @CustomerIdentificationIdCountry, @CustomerIdentificationIdState
							END
						DELETE FROM @tableUploads WHERE IdUpload = @IdUploadf 
					END
			END

		SET @Message = 'Customer Information has been successfully saved'
		SET @HasError = 0

	END

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage=ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('[Corp].[st_UpdateCustomerInformation]', GETDATE(), @ErrorMessage)
	SET @HasError=1	
END CATCH

