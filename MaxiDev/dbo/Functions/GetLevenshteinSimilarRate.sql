CREATE FUNCTION GetLevenshteinSimilarRate
(
	@InputOriginal		NVARCHAR(4000),
	@InputCompare		NVARCHAR(4000)
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @Distance	INT,
			@Len		INT
	SELECT
		@InputOriginal = ISNULL(@InputOriginal, ''),
		@InputCompare = ISNULL(@InputCompare, '')

	SET @Distance = dbo.fnLevenshtein(@InputOriginal, @InputCompare, NULL)


	IF LEN(@InputOriginal) > LEN(@InputCompare)
		SET @Len = LEN(@InputOriginal)
	ELSE
		SET @Len = LEN(@InputCompare)
		
	IF ISNULL(@Len, 0) = 0
		SET @Len = 1

	RETURN CAST((ABS((CAST(@Distance AS FLOAT) / @Len) - 1) * 100) AS NUMERIC(6, 2))
END