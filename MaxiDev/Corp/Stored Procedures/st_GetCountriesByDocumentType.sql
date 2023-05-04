CREATE PROCEDURE [Corp].[st_GetCountriesByDocumentType] 
	@IdCountry 		INT = NULL,
	@IdDocumentType	INT = null
AS
BEGIN

	SET NOCOUNT ON;
	
	SELECT DISTINCT C.IdCountry, C.CountryName, C.CountryCode, C.DateOfLastChange, C.EnterByIdUser
	FROM dbo.Country C WITH(NOLOCK) INNER JOIN
	 	CustomerIdentifTypeByCountry D WITH(NOLOCK) ON D.IdCountry = C.IdCountry
	WHERE (C.IdCountry = @IdCountry OR isnull(@IdCountry, 0) = 0)
		AND (D.IdDocument = @IdDocumentType OR isnull(@IdDocumentType, 0) = 0)
	ORDER BY IdCountry
   
END

