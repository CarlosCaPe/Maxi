CREATE PROCEDURE Corp.st_GetOfacValidationCatalogs
AS
BEGIN
	
	SELECT IdOfacValidation, 
		DateOfCreation, 
		FORMAT(DateOfCreation, 'MM/dd/yyyy hh:mm:ss') + ' ' + FileName AS Description,
		FileName,
		FORMAT(DateOfCreation, 'yyyyMMdd_hhmmss') AS FormatDate
	FROM Corp.OfacValidation
	ORDER BY DateOfCreation DESC
	
	SELECT Code AS 'OfacValidationStatusCode', Name AS 'OfacValidationStatusName'
	FROM Corp.OfacValidationStatus
	
	SELECT IdOfacValidationEntityType, Name
	FROM Corp.OfacValidationEntityType

END



