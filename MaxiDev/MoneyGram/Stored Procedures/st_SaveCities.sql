CREATE PROCEDURE MoneyGram.st_SaveCities
(
	@CountryCode		VARCHAR(10),
	@StateProvinceCode	VARCHAR(10),
	@Cities				XML,
	@AgentId			VARCHAR(200)
)
AS
BEGIN

	DECLARE @NewCities TABLE(IdCity INT)

	;WITH XMLCatalog AS
    (
        SELECT DISTINCT
            t.c.value('CityName[1]', 'varchar(200)') CityName
        FROM @Cities.nodes('root/City') t(c)
    )
    MERGE MoneyGram.City AS t
    USING XMLCatalog c ON 
		ISNULL(t.CountryCode, '') = ISNULL(@CountryCode, '')
		AND ISNULL(t.StateProvinceCode, '') = ISNULL(@StateProvinceCode, '')
		AND ISNULL(t.CityName, '') = ISNULL(c.CityName, '')
    WHEN MATCHED THEN
        UPDATE SET
            DateOfLastChange = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT (
            CountryCode,
            StateProvinceCode,
            CityName,
            DateOfLastChange, 
            CreationDate,
			Active
        )
        VALUES (
            @CountryCode,
            @StateProvinceCode,
            c.CityName,
            NULL, 
            GETDATE(),
			1
        )
	OUTPUT INSERTED.IdCity INTO @NewCities(IdCity);

	UPDATE MoneyGram.City SET
		Active = 0,
		DateOfLastChange = GETDATE()
	WHERE ISNULL(CountryCode, '') = ISNULL(@CountryCode, '')
	AND ISNULL(StateProvinceCode, '') = ISNULL(@StateProvinceCode, '')
	AND NOT EXISTS (SELECT * FROM @NewCities nc WHERE nc.IdCity = City.IdCity)

END