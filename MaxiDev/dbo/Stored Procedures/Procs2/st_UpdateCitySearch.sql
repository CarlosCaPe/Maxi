CREATE PROCEDURE st_UpdateCitySearch
(
	@IdCity	INT
)
AS
BEGIN
	DECLARE @CityNameRaw			VARCHAR(500),
			@CityNameAppend			VARCHAR(500),
			@CityNameClean			VARCHAR(500),
			@IdState				INT

	SELECT
		@CityNameRaw = UPPER(c.CityName),
		@IdState = c.IdState
	FROM City c WITH (NOLOCK) 
	WHERE c.IdCity = @IdCity
	
	IF ISNULL(@CityNameRaw, '') = ''
	BEGIN
		DELETE FROM CitySearch WHERE IdCity = @IdCity
		RETURN
	END

	SET @CityNameAppend = dbo.PhoneticStandardize(@CityNameRaw, 0)
	SET @CityNameClean = dbo.PhoneticStandardize(@CityNameRaw, 1)

	IF EXISTS (SELECT 1 FROM CitySearch cs WHERE cs.IdCity = @IdCity)
		UPDATE CitySearch SET
			CityNameRaw = @CityNameRaw,
			CityNameAppend = @CityNameAppend,
			CityNameClean = @CityNameClean
		WHERE IdCity = @IdCity
	ELSE
		INSERT INTO CitySearch
		(
			IdCity, 
			IdState,
			CityNameRaw, 
			CityNameAppend, 
			CityNameClean
		)
		VALUES
		(
			@IdCity,
			@IdState,
			@CityNameRaw,
			@CityNameAppend,
			@CityNameClean
		)
END