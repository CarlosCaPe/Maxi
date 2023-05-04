CREATE PROCEDURE [dbo].[st_SaveCustomerCatalog]
(
	@IdCustomer INT,
    @Name NVARCHAR(MAX),
    @FirstLastName NVARCHAR(MAX),
    @SecondLastName NVARCHAR(MAX),
    @Address NVARCHAR(MAX),
    @City NVARCHAR(MAX),
    @State NVARCHAR(MAX),
	@Country NVARCHAR(MAX),
	@IDNumber NVARCHAR(MAX),
	@IdCustomerIdentificationType INT,
	@IdExpirationDate DATETIME,
	@BirthDate DATETIME,
	@IdCountryBirth INT,
    @Zipcode NVARCHAR(MAX),
    @PhoneNumber NVARCHAR(MAX),
    @CelullarNumber NVARCHAR(MAX),
	@Occupation NVARCHAR(MAX),
	@OccupationDetail NVARCHAR(MAX),
	@SSN NVARCHAR(20),
    @IdCarrier  INT,
    @EnterByIdUser INT,
    @IdLenguage int,
    @HasError bit out, 
	@ResultMessage nvarchar(max) out
)
AS
BEGIN
SET NOCOUNT ON;
	DECLARE @IdGenericStatusEnable INT
	SET @IdGenericStatusEnable =1 --Enable
	DECLARE @IdGenericStatusDisable INT
	SET @IdGenericStatusDisable =1 --Disable

	--** validations 
	IF ((SELECT LEN(@SSN))<>11)
	BEGIN 
		SET @ResultMessage = 'SSN is not in a correct format' 
		SET @HasError = 1
		RETURN
	END
	IF ((SELECT SUBSTRING(@SSN,1,3))='000' OR (SELECT SUBSTRING(@SSN,1,3))='666' OR (SELECT CONVERT(int,SUBSTRING(@SSN,1,3)))>772)
	BEGIN 
		SET @ResultMessage = 'SSN is not in a correct format' 
		SET @HasError = 1
		RETURN
	END
	IF ((SELECT SUBSTRING(@SSN,5,2))='00')
	BEGIN
		SET @ResultMessage = 'SSN is not in a correct format' 
		SET @HasError = 1
		RETURN
	END
	IF ((SELECT SUBSTRING(@SSN,8,4))='0000')
	BEGIN
		SET @ResultMessage = 'SSN is not in a correct format' 
		SET @HasError = 1
		RETURN
	END


	IF @IdLenguage IS NULL  
		SET @IdLenguage=2

	BEGIN TRY
                EXEC st_SaveCustomerMirror @IdCustomer
				
				UPDATE [dbo].[Customer]
					   SET 
						  [IdGenericStatus] = @IdGenericStatusEnable
						  ,[Name] =@Name
						  ,[FirstLastName] = @FirstLastName
						  ,[SecondLastName] = @SecondLastName
						  ,[Address] = @Address
						  ,[City] = @City
						  ,[State] = @State
						  ,[Country] = @Country
						  ,[Zipcode] = @Zipcode
						  ,[BornDate]=@BirthDate
						  ,[IdCountryOfBirth]=@IdCountryBirth
						  ,[Occupation]=@Occupation
						  ,[OccupationDetail]=@OccupationDetail
						  ,[PhoneNumber] = @PhoneNumber
						  ,[CelullarNumber] = @CelullarNumber
						  ,[IdentificationNumber] =@IDNumber
						  ,[ExpirationIdentification]=@IdExpirationDate
						  ,[IdCustomerIdentificationType]=@IdCustomerIdentificationType
						  ,[SSNumber]=@SSN
						  --,[IdCarrier]=@IdCarrier
                          ,[DateOfLastChange] = getdate()
					      ,[EnterByIdUser] = @EnterByIdUser
                          						  
					 WHERE IdCustomer = @IdCustomer                

		SET @HasError =0
		SET @ResultMessage = [dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,'MESSAGE10')
        SELECT @ResultMessage, @IdCustomer
	END TRY
	BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(MAX)         
			SELECT @ErrorMessage=ERROR_MESSAGE()        
			SET @HasError =1
			SELECT @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE11')
	END CATCH

RETURN;

END                                                             
