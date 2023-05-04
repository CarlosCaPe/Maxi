CREATE PROCEDURE MoneyGram.st_GetEnumerated
(
	@IdEnumeratedType	INT,
	@IdReference		VARCHAR(100)
)
AS
BEGIN
	SELECT
		e.*
	FROM MoneyGram.Enumerators e
		JOIN MoneyGram.EnumeratorMap m ON m.IdEnumerator = e.IdEnumerator
	WHERE e.IdEnumeratedType = @IdEnumeratedType
	AND m.IdReference = @IdReference
END
