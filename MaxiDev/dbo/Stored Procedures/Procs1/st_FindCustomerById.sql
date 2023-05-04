
CREATE PROCEDURE [dbo].[st_FindCustomerById]
    @IdCustomers int
AS
BEGIN

	SELECT
		c.IdCustomer,
		c.IdAgentCreatedBy,
		c.IdCustomerIdentificationType,
		c.IdGenericStatus,
		c.Name,
		c.FirstLastName,
		c.SecondLastName,
		c.Address,
		c.City,
		c.State,
		c.Country,
		c.Zipcode,
		c.PhoneNumber,
		c.CelullarNumber,
		c.SSNumber,
		c.BornDate,
		c.Occupation,
		c.IdentificationNumber,
		c.PhysicalIdCopy,
		c.DateOfLastChange,
		c.EnterByIdUser,
		c.ExpirationIdentification,
		c.IdCarrier,
		c.IdentificationIdCountry,
		c.IdentificationIdState,
		c.SentAverage,
		c.FullName,
		c.IdCountryOfBirth,
		c.ReceiveSms,
		c.CreationDate,
		c.OccupationDetail,
		c.IdTypeTax,
		c.HasAnswerTaxId,
		c.IdOccupation,
		c.IdSubcategoryOccupation,
		c.SubcategoryOccupationOther,
		c.IdDialingCodePhoneNumber

	FROM Customer c WITH(NOLOCK)
	WHERE c.IdCustomer = @IdCustomers

END