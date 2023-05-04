CREATE PROCEDURE [dbo].[st_FetchOwner]
(
	@Name		       VARCHAR(200),
	@State		       VARCHAR(200),
	@ZipCode	       VARCHAR(200),
	@Phone	           VARCHAR(200),
	@Cellular          VARCHAR(200),
	@Ssn               VARCHAR(200),
    @ShowAll	       BIT = 0,
	@Offset			   BIGINT,
	@Limit			   BIGINT
)
AS
/********************************************************************
<Author></Author>
<app>CorporativeServices.Catalogs</app>
<Description>This stored is used in CorporativeServices on Catalogs Controller</Description>

<ChangeLog>
<log Date="15/08/2022" Author="maprado">Add @Ssn parameter </log>
<log Date="15/08/2022" Author="maprado">Add IdStateEmission & IdCountryEmission to result </log>
<log Date="01/03/2023" Author="maprado">BM-1048 - Modify to search SSN without Mask </log>
</ChangeLog>
*********************************************************************/
BEGIN
	IF (@ShowAll = 1 and @ShowAll is not null) 
	BEGIN
		SELECT 
			COUNT(*) OVER() _PagedResult_Total,
			cc.IdOwner, cc.Name, cc.LastName, cc.SecondLastName, cc.Address, cc.City, cc.State, cc.Zipcode, 
			cc.Phone, cc.Cel, cc.Email, cc.SSN, cc.IdType, cc.IdNumber, IdExpirationDate, cc.BornDate, cc.BornCountry, 
			cc.CreationDate, cc.DateOfLastChange, cc.EnterByIdUser, cc.IdStatus, cc.CreditScore,
			cc.IdCounty, cc.IdStateEmission, cc.IdCountryEmission
			FROM Owner AS cc WITH (NOLOCK) 
		WHERE 	
			@Name IS NULL OR cc.Name LIKE CONCAT('%', @Name, '%') -- @Name
			AND (@State IS NULL OR cc.State = @State) -- @Code
			AND (@ZipCode IS NULL OR cc.ZipCode = @ZipCode) -- @Code
			AND (@Phone IS NULL OR cc.Phone = @Phone) -- @Code
			AND (@Cellular IS NULL OR cc.Cel = @Cellular) -- @Code
			AND (@Ssn IS NULL OR REPLACE(cc.SSN,'-','') LIKE CONCAT('%', @Ssn, '%') )-- BM-1048
		ORDER BY cc.IdOwner
		OFFSET (@Offset) ROWS
		FETCH NEXT @Limit ROWS ONLY
	END
	ELSE 
	BEGIN
	SELECT 
			COUNT(*) OVER() _PagedResult_Total,
			cc.IdOwner, cc.Name, cc.LastName, cc.SecondLastName, cc.Address, cc.City, cc.State, cc.Zipcode, 
			cc.Phone, cc.Cel, cc.Email, cc.SSN, cc.IdType, cc.IdNumber, IdExpirationDate, cc.BornDate, cc.BornCountry, 
			cc.CreationDate, cc.DateOfLastChange, cc.EnterByIdUser, cc.IdStatus, cc.CreditScore,
			cc.IdCounty, cc.IdStateEmission, cc.IdCountryEmission
			FROM Owner AS cc WITH(NOLOCK) 
		WHERE 	
			cc.IdStatus=1
			AND (@Name IS NULL OR cc.Name LIKE CONCAT('%', @Name, '%')) -- @Name
			AND (@State IS NULL OR cc.State = @State) -- @Code
			AND (@ZipCode IS NULL OR cc.ZipCode = @ZipCode) -- @Code
			AND (@Phone IS NULL OR cc.Phone = @Phone) -- @Code
			AND (@Cellular IS NULL OR cc.Cel = @Cellular) -- @Code
			AND (@Ssn IS NULL OR REPLACE(cc.SSN,'-','') LIKE CONCAT('%', @Ssn, '%') )-- BM-1048
		ORDER BY cc.IdOwner
		OFFSET (@Offset) ROWS
		FETCH NEXT @Limit ROWS ONLY
	END

END