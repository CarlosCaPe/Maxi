CREATE PROCEDURE [dbo].[stExampleGetCityByCountry]
    @IdCountryList VARCHAR(MAX) = NULL
AS
/********************************************************************
<Author>elopez</Author> 
<app>This is an example procedure and should not be used in other apps</app> 
<Description>This is an example procedure and should not be used in other app</Description>
*********************************************************************/
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT
            c2.IdCity,
            c.IdCountry,
            c2.IdState,
            c2.CityName 
        FROM dbo.Country AS c WITH (NOLOCK)
        INNER JOIN dbo.[State] AS s WITH (NOLOCK) ON
            s.IdCountry = c.IdCountry 
        INNER JOIN dbo.City AS c2 WITH (NOLOCK) ON
            c2.IdState = s.IdState
        WHERE
            c.IdCountry IN (SELECT CAST([value] AS INT) FROM STRING_SPLIT(@IdCountryList, ','))
        ORDER BY c2.IdCity;
    END TRY 
	BEGIN CATCH
		INSERT INTO dbo.ErrorLogForStoreProcedure (
			StoreProcedure,
			ErrorDate,
			ErrorMessage
		)
		VALUES (
			CONCAT(SCHEMA_NAME(), '.', ERROR_PROCEDURE()), 
			GETDATE(), 
			CONCAT(ERROR_MESSAGE(), '|Line: ', CONVERT(varchar(10), ERROR_LINE()))
		);
	END CATCH;
END