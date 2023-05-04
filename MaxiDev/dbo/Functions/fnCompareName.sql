CREATE FUNCTION fnCompareName
(
	@OriginalName	NVARCHAR(1000),
	@CompareName	NVARCHAR(1000)
)
RETURNS TABLE
RETURN
(
	WITH cte AS
	(
	SELECT
		COUNT(DISTINCT fso.id) TotalWords,
		COUNT(DISTINCT fsc.id) SimilarWords
	FROM FnSplitTable(@OriginalName, ' ') fso
		LEFT JOIN dbo.FnSplitTable(@CompareName, ' ') fsc ON
			dbo.GetLevenshteinSimilarRate(fso.part, fsc.part) > 80
	) 
	SELECT
		CASE 
			WHEN c.SimilarWords = 1 THEN 0
			ELSE CASE WHEN c.SimilarWords >= (CASE WHEN c.TotalWords = 1 THEN 1 ELSE FLOOR(c.TotalWords * .70) END) THEN 1 ELSE 0 END
		END Success,
		c.SimilarWords,
		c.TotalWords
	FROM cte c
)
