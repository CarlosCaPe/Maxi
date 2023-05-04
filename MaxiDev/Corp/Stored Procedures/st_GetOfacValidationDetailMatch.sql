CREATE PROCEDURE Corp.st_GetOfacValidationDetailMatch
	@IdOfacValidationDetail INT
	
AS
BEGIN
	
	SELECT O.IdOfacValidationDetailMatch, 
			O.NameComplete + ', Score: ' + convert(VARCHAR(10), O.Score) + ', Remarks: ' + O.Remarks AS MatchDescription,
			O.NameComplete AS MatchName,
			M.Score, 
			M.Status, 
			M.EntNum, 
			M.AltNum, 
			isnull(M.Name, 'N/A') AS 'Name', 
			M.LastName, 
			isnull(M.NameComplete, 'N/A') AS 'NameComplete', 
			M.Remarks, 
			M.Type, 
			M.Address, 
			M.CityName, 
			M.Country, 
			M.AddRemarks
	FROM corp.OfacValidationDetailMatch O WITH(NOLOCK) LEFT JOIN
		Corp.OfacValidationDetailMatchAka M WITH(NOLOCK) ON M.IdOfacValidationDetailMatch = O.IdOfacValidationDetailMatch
		
	WHERE IdOfacValidationDetail = @IdOfacValidationDetail

END
