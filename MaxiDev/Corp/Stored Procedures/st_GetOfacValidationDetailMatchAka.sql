CREATE PROCEDURE Corp.st_GetOfacValidationDetailMatchAka
	@IdOfacValidationDetailMatch INT
AS
BEGIN

	SELECT O.Score, O.Status, O.EntNum, O.AltNum, O.Name, O.LastName, O.NameComplete, O.Remarks, O.Type, O.Address, O.CityName, O.Country, O.AddRemarks
	FROM Corp.OfacValidationDetailMatchAka O
	WHERE IdOfacValidationDetailMatch = @IdOfacValidationDetailMatch

END
