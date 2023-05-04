CREATE PROCEDURE st_FindCountryById
(
	@IdCountry	INT
)
AS
BEGIN
	SELECT
		c.*
	FROM Country c 
	WHERE c.IdCountry = @IdCountry
END