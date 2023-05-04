CREATE PROCEDURE [dbo].[st_FetchCustomers]
(
	@Name				VARCHAR(200),
	@FirstLastName		VARCHAR(200),
	@SecondLastName		VARCHAR(200),

	@Offset				BIGINT,
	@Limit				BIGINT
)
AS
BEGIN

	SELECT 
		COUNT(*) OVER() _PagedResult_Total,
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
		c.SubcategoryOccupationOther
	FROM Customer c WITH(NOLOCK)
	WHERE
		(@Name IS NULL OR c.Name LIKE CONCAT('%', @Name, '%'))
		AND (@FirstLastName IS NULL OR c.FirstLastName LIKE CONCAT('%', @FirstLastName, '%'))
		AND (@SecondLastName IS NULL OR c.SecondLastName LIKE CONCAT('%', @SecondLastName, '%'))
	ORDER BY IdCustomer
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY
END
