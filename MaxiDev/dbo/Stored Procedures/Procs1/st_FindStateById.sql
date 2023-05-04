CREATE PROCEDURE st_FindStateById
(
	@IdState		INT,
	@IdCountry		INT
)
AS
BEGIN

	SELECT 
		s.*
	FROM State s 
	WHERE s.IdState = @IdState
	AND s.IdCountry = @IdCountry

END