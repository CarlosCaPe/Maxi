CREATE PROCEDURE st_NSGetNetSuiteConfig
AS
BEGIN
	SELECT
		c.Name,
		c.Value 
	FROM NetSuiteConfig c
END
