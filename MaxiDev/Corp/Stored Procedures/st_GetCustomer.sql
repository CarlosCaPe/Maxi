CREATE PROCEDURE [Corp].[st_GetCustomer] 
	@IdCustomer int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [IdCustomer]
      ,[IdAgentCreatedBy]
      ,[IdCustomerIdentificationType]
      ,[IdGenericStatus]
      ,[Name]
      ,[FirstLastName]
      ,[SecondLastName]
      ,[Address]
      ,[City]
      ,[State]
      ,[Country]
      ,[Zipcode]
      ,[PhoneNumber]
      ,[CelullarNumber]
      ,[SSNumber]
      ,[BornDate]
      ,[Occupation]
      ,[IdentificationNumber]
      ,[PhysicalIdCopy]
      ,[DateOfLastChange]
      ,[EnterByIdUser]
      ,[ExpirationIdentification]
      ,[IdCarrier]
      ,[IdentificationIdCountry]
      ,[IdentificationIdState]
      ,[SentAverage]
      ,[FullName]
      ,[IdCountryOfBirth]
      ,[ReceiveSms]
      ,[CreationDate]
      ,[OccupationDetail]
      ,[idElasticCustomer]
      ,[RequestUpdate]
      ,[UpdateCompleted]
	FROM [dbo].[Customer] WITH(NOLOCK)
	WHERE IdCustomer = @IdCustomer

END
