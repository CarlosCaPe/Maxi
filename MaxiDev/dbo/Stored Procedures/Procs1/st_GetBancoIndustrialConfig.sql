CREATE PROCEDURE st_GetBancoIndustrialConfig
AS
BEGIN

	WITH Config AS
	(
		SELECT
			ga.Name,
			ga.Value
		FROM GlobalAttributes ga 
		WHERE ga.Name IN ('WebServiceRoute', 'percentLimit', 'UserWS', 'PassWS')
	)
	SELECT
		'01' Origin,
		MAX(CASE WHEN c.Name = 'WebServiceRoute' THEN c.Value END) [URL],
		MAX(CASE WHEN c.Name = 'UserWS' THEN c.Value END) [Login],
		MAX(CASE WHEN c.Name = 'PassWS' THEN c.Value END) [Password],
		CAST(MAX(CASE WHEN c.Name = 'percentLimit' THEN c.Value END) AS INT) PercentLimit
	FROM Config c
END
