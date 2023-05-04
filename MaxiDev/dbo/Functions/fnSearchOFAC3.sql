CREATE FUNCTION [dbo].[fnSearchOFAC3]
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
	DECLARE	@TotalLen						INT,
			@MinQualificationName			INT,
			@MinQualificationFirstLastName	INT,
			@MinQualificationSecodLastName	INT

	DECLARE @SplitName TABLE (WordClean		NVARCHAR(200))
	DECLARE @SplitLastName TABLE (WordClean		NVARCHAR(200))

	INSERT INTO @SplitName
	SELECT dbo.ClearContractions(fs.item) FROM dbo.fnSplit(@Name, ' ') fs

	INSERT INTO @SplitLastName
	SELECT dbo.ClearContractions(fs.item) FROM dbo.fnSplit(CONCAT(@FirstLastName, ' ', @SecondLastName), ' ') fs


	SET @TotalLen = (SELECT COUNT(1) FROM @SplitName) + (SELECT COUNT(1) FROM @SplitLastName)


	IF (SELECT MIN(LEN(sn.WordClean)) FROM @SplitName sn) <= 5
		SET @MinQualificationName = 50
	ELSE
		SET @MinQualificationName = 70

	IF LEN(@FirstLastName) <= 5
		SET @MinQualificationFirstLastName = 50
	ELSE
		SET @MinQualificationFirstLastName = 70

	IF LEN(@SecondLastName) <= 5
		SET @MinQualificationSecodLastName = 50
	ELSE
		SET @MinQualificationSecodLastName = 70

	;WITH Result AS
	(
		SELECT
			os.EntNum,
			os.AltNum,
			(
				SELECT CAST(SUM(ISNULL(L.Q, 0)) AS FLOAT) / SUM(CASE WHEN L.Q IS NULL THEN 0 ELSE 1 END) FROM
				(
					SELECT dbo.GetLevenshteinSimilarRate(os.Name1, sn.WordClean) Q FROM @SplitName sn WHERE dbo.GetLevenshteinSimilarRate(os.Name1, sn.WordClean) >= @MinQualificationName
					UNION
					SELECT dbo.GetLevenshteinSimilarRate(os.Name2, sn.WordClean) Q FROM @SplitName sn WHERE dbo.GetLevenshteinSimilarRate(os.Name2, sn.WordClean) >= @MinQualificationName
					UNION
					SELECT dbo.GetLevenshteinSimilarRate(os.Name3, sn.WordClean) Q FROM @SplitName sn WHERE dbo.GetLevenshteinSimilarRate(os.Name3, sn.WordClean) >= @MinQualificationName
					UNION
					SELECT dbo.GetLevenshteinSimilarRate(os.LastName1, sn.WordClean) Q FROM @SplitLastName sn WHERE dbo.GetLevenshteinSimilarRate(os.LastName1, sn.WordClean) >= @MinQualificationFirstLastName
					UNION
					SELECT dbo.GetLevenshteinSimilarRate(os.LastName2, sn.WordClean) Q FROM @SplitLastName sn WHERE dbo.GetLevenshteinSimilarRate(os.LastName2, sn.WordClean) >= @MinQualificationSecodLastName
				) L
			) SimilarQualification,
			(
				(
					SELECT COUNT(1) FROM dbo.fnSplit(@Name, ' ') sn 
					WHERE dbo.GetLevenshteinSimilarRate(os.Name1, sn.item) >= @MinQualificationName
						OR dbo.GetLevenshteinSimilarRate(os.Name2, sn.item) >= @MinQualificationName
						OR dbo.GetLevenshteinSimilarRate(os.Name3, sn.item) >= @MinQualificationName
				) + 
				(
					SELECT COUNT(1) FROM  dbo.fnSplit(CONCAT(@FirstLastName, ' ', @SecondLastName), ' ') sn 
					WHERE dbo.GetLevenshteinSimilarRate(os.LastName1, sn.item) >= @MinQualificationFirstLastName
						OR dbo.GetLevenshteinSimilarRate(os.LastName2, sn.item) >= @MinQualificationSecodLastName
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
