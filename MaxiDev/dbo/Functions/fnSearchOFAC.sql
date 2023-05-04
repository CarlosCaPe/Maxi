CREATE FUNCTION fnSearchOFAC
(
	@Name			NVARCHAR(MAX),
	@FirstLastName	NVARCHAR(MAX),
	@SecondLastName	NVARCHAR(MAX)
)
RETURNS TABLE
RETURN
(
	WITH Result AS
	(
		SELECT
			(
				SELECT COUNT(1) FROM dbo.fnSplit(@Name, ' ') sn 
				WHERE dbo.GetLevenshteinSimilarRate(os.Name1, sn.item) > 80
					OR dbo.GetLevenshteinSimilarRate(os.Name2, sn.item) > 80
					OR dbo.GetLevenshteinSimilarRate(os.Name3, sn.item) > 80
			) SimilarName,
			(
				SELECT COUNT(1) FROM  dbo.fnSplit(CONCAT(@FirstLastName, ' ', @SecondLastName), ' ') sn 
				WHERE dbo.GetLevenshteinSimilarRate(os.LastName1, sn.item) > 80
					OR dbo.GetLevenshteinSimilarRate(os.LastName2, sn.item) > 80
			) SimilarLastName,
			os.EntNum,
			os.AltNum
		FROM OfacSplit os
	)
	SELECT
		r.EntNum,
		r.AltNum,
		ISNULL(al.alt_name, sd.SDN_name) Name,
		(CAST((r.SimilarName + r.SimilarLastName) AS FLOAT) / t.TotalLen) * 100 Qualification
	FROM Result r
		JOIN OFAC_SDN sd ON sd.ent_num = r.EntNum
		LEFT JOIN OFAC_ALT al ON al.alt_num = r.AltNum AND al.ent_num = r.EntNum
	CROSS APPLY (SELECT COUNT(1) TotalLen FROM dbo.fnSplit(CONCAT(@Name, ' ', @FirstLastName, ' ', @SecondLastName), ' ')) t
	WHERE r.SimilarName + r.SimilarLastName >= 1
)
