CREATE PROCEDURE st_NSGetConfiguration
AS
BEGIN
	SELECT
		c.Name,
		c.Value 
	FROM NSConfiguration c
END