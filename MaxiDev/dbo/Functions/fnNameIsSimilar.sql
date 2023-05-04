CREATE FUNCTION fnNameIsSimilar
(
	@OriginalName	NVARCHAR(1000),
	@CompareName	NVARCHAR(1000)
)
RETURNS BIT
AS
BEGIN
	RETURN CASE 
		WHEN EXISTS(SELECT 1 FROM dbo.fnCompareName(@OriginalName, @CompareName) c WHERE c.Success = 1 ) THEN 1
		ELSE 0
	END
END