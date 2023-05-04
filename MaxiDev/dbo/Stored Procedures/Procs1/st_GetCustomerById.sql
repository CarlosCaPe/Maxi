CREATE PROCEDURE [dbo].[st_GetCustomerById]
(
 	@IdCustomer INT
)
AS
BEGIN
SET NOCOUNT ON;


	IF (ISNULL(@IdCustomer,0)>0)
	BEGIN
		SELECT 
		IdCustomer, 
		Name, 
		FirstLastName, 
		SecondLastName , 
		BornDate, 
		Address,
		City, 
		State, 
		ZipCode, 
		Country , 
		PhoneNumber, 
		CelullarNumber,
		IdCarrier,
		SSNumber,
		Occupation,
		OccupationDetail,
		IdCustomerIdentificationType,
		IdentificationNumber,
		IdentificationIdCountry,
		IdentificationIdState,
		ExpirationIdentification,
		DateOfLastChange, 
		EnterByIdUser,
		IdCountryOfBirth
		FROM Customer
		WHERE IdCustomer = @IdCustomer
	END
	
END 
