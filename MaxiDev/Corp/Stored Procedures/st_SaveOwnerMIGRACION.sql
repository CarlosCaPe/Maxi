CREATE PROCEDURE [Corp].[st_SaveOwnerMIGRACION]
(
	@IdOwner int,
	@Name nvarchar(max),
    @LastName nvarchar(max),
    @SecondLastName nvarchar(max),
    @Address nvarchar(max),
    @City nvarchar(max),
    @State nvarchar(max),
    @Zipcode nvarchar(max),
    @Phone nvarchar(max),
    @Cel nvarchar(max),
    @Email nvarchar(max),
    @SSN nvarchar(max),
    @IdType nvarchar(max),
    @IdNumber nvarchar(max),
    @IdExpirationDate datetime = NULL,
    @BornDate datetime = NULL,
    @BornCountry nvarchar(max),
    @EnterByIdUser int,
    @IdStatus int,
    @CreditScore nvarchar(max) = '0',
    @IdCounty int,
    @IdStateEmission INT,
    @IdCountryEmission INT,
    @HasError int out,
    @Message nvarchar(max) out
)
AS
SET NOCOUNT ON;
BEGIN 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET @HasError = 0
	SET @Message = ''
	BEGIN TRY
		IF (@IdOwner = 0)
			BEGIN
				INSERT INTO [dbo].[Owner] ([Name], [LastName], [SecondLastName], [Address], [City], [State], [Zipcode], [Phone], [Cel], [Email], [SSN], [IdType], [IdNumber], [IdExpirationDate], 
					[BornDate], [BornCountry], [CreationDate], [DateofLastChange], [EnterByIdUser], [IdStatus], [CreditScore], [IdCounty], [IdStateEmission], [IdCountryEmission])
				VALUES (@Name, @LastName, @SecondLastName, @Address, @City, @State, @Zipcode, @Phone, @Cel, @Email, @SSN, @IdType, @IdNumber, @IdExpirationDate, @BornDate, @BornCountry, GETDATE(),
					GETDATE(), @EnterByIdUser, @IdStatus, @CreditScore, @IdCounty, @IdStateEmission, @IdCountryEmission)
			END
		ELSE 
			BEGIN
				UPDATE [dbo].[Owner]
				SET [Name] = @Name, 
					[LastName] = @LastName, 
					[SecondLastName] = @SecondLastName, 
					[Address] = @Address, 
					[City] = @City, 
					[State] = @State, 
					[Zipcode] = @Zipcode, 
					[Phone] = @Phone, 
					[Cel] = @Cel, 
					[Email] = @Email, 
					[SSN] = @SSN, 
					[IdType] = @IdType, 
					[IdNumber] = @IdNumber, 
					[IdExpirationDate] = @IdExpirationDate, 
					[BornDate] = @BornDate, 
					[BornCountry] = @BornCountry, 
					[DateofLastChange] = GETDATE(),
					[EnterByIdUser] = @EnterByIdUser, 
					[IdStatus] = @IdStatus,
					[CreditScore] = @CreditScore, 
					[IdCounty] = @IdCounty,
					[IdStateEmission] = @IdStateEmission,
					[IdCountryEmission] = @IdCountryEmission
				WHERE IdOwner = @IdOwner
			END
	END TRY
	BEGIN CATCH 
		SET @HasError = 1
		SET @Message = ERROR_MESSAGE()
	END CATCH
END

