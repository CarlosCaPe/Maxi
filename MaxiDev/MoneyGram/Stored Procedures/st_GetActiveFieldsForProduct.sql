CREATE PROCEDURE MoneyGram.st_GetActiveFieldsForProduct
AS
BEGIN
	SELECT * FROM MoneyGram.FieldsForProduct f
	WHERE f.Active = 1
END

