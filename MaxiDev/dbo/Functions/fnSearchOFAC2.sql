CREATE FUNCTION [dbo].[fnSearchOFAC2]
(
	@Name			NVARCHAR(MAX),
	@FirstLastName	NVARCHAR(MAX),
	@SecondLastName	NVARCHAR(MAX)
)
RETURNS @Result TABLE 
(
	EntNum					BIGINT,
	AltNum					BIGINT,
	Name					NVARCHAR(1000),
	SimilarQualification	FLOAT,
	CountQualification		FLOAT,
	TotalQualification		FLOAT
)
BEGIN
	DECLARE	@TotalLen			INT,
			@MinQualification	INT

	DECLARE @SplitName TABLE (WordClean		NVARCHAR(200))
	DECLARE @SplitLastName TABLE (WordClean		NVARCHAR(200))

	INSERT INTO @SplitName
	SELECT dbo.ClearContractions(fs.item) FROM dbo.fnSplit(@Name, ' ') fs

	INSERT INTO @SplitLastName
	SELECT dbo.ClearContractions(fs.item) FROM dbo.fnSplit(CONCAT(@FirstLastName, ' ', @SecondLastName), ' ') fs


	SET @TotalLen = (SELECT COUNT(1) FROM @SplitName) + (SELECT COUNT(1) FROM @SplitLastName)
	SET @MinQualification = 70

	;WITH Result AS
	(
		SELECT
			os.EntNum,
			os.AltNum,
			(
				SELECT CAST(SUM(ISNULL(L.Q, 0)) AS FLOAT) / SUM(CASE WHEN L.Q IS NULL THEN 0 ELSE 1 END) FROM
				(
					SELECT dbo.GetLevenshteinSimilarRate(os.Name1, sn.WordClean) Q FROM @SplitName sn WHERE dbo.GetLevenshteinSimilarRate(os.Name1, sn.WordClean) >= @MinQualification
					UNION
					SELECT dbo.GetLevenshteinSimilarRate(os.Name2, sn.WordClean) Q FROM @SplitName sn WHERE dbo.GetLevenshteinSimilarRate(os.Name2, sn.WordClean) >= @MinQualification
					UNION
					SELECT dbo.GetLevenshteinSimilarRate(os.Name3, sn.WordClean) Q FROM @SplitName sn WHERE dbo.GetLevenshteinSimilarRate(os.Name3, sn.WordClean) >= @MinQualification
					UNION
					SELECT dbo.GetLevenshteinSimilarRate(os.LastName1, sn.WordClean) Q FROM @SplitLastName sn WHERE dbo.GetLevenshteinSimilarRate(os.LastName1, sn.WordClean) >= @MinQualification
					UNION
					SELECT dbo.GetLevenshteinSimilarRate(os.LastName2, sn.WordClean) Q FROM @SplitLastName sn WHERE dbo.GetLevenshteinSimilarRate(os.LastName2, sn.WordClean) >= @MinQualification
				) L
			) SimilarQualification,
			(
				(
					SELECT COUNT(1) FROM dbo.fnSplit(@Name, ' ') sn 
					WHERE dbo.GetLevenshteinSimilarRate(os.Name1, sn.item) >= @MinQualification
						OR dbo.GetLevenshteinSimilarRate(os.Name2, sn.item) >= @MinQualification
						OR dbo.GetLevenshteinSimilarRate(os.Name3, sn.item) >= @MinQualification
				) + 
				(
					SELECT COUNT(1) FROM  dbo.fnSplit(CONCAT(@FirstLastName, ''), ' ') sn 
					WHERE dbo.GetLevenshteinSimilarRate(os.LastName1, sn.item) >= @MinQualification
						OR dbo.GetLevenshteinSimilarRate(os.LastName2, sn.item) >= @MinQualification
				)
			) SimilarCount
		FROM OfacSplit os
	), ResultQ AS
	(
		SELECT
			r.EntNum,
			r.AltNum,
			r.SimilarQualification,
			(CAST(r.SimilarCount AS FLOAT) / t.TotalLen) * 100 CountQualification,
			(r.SimilarQualification + ((CAST(r.SimilarCount AS FLOAT) / t.TotalLen) * 100)) / 2 TotalQualification
		FROM Result r
		CROSS APPLY (SELECT COUNT(1) TotalLen FROM dbo.fnSplit(CONCAT(@Name, ' ', @FirstLastName, ' ', @SecondLastName), ' ')) t
		WHERE r.SimilarQualification > 0
	)
	INSERT INTO @Result
	SELECT
		q.EntNum,
		q.AltNum,
		ISNULL(al.alt_name, sd.SDN_name) Name,
		q.SimilarQualification,
		q.CountQualification,
		q.TotalQualification
	FROM ResultQ q
		JOIN OFAC_SDN sd ON sd.ent_num = q.EntNum
		LEFT JOIN OFAC_ALT al ON al.alt_num = q.AltNum AND al.ent_num = q.EntNum

	RETURN;
END
