CREATE TYPE [DTOne].[CountriesType] AS TABLE (
    [CountryCode] NVARCHAR (3)   NULL,
    [CountryName] NCHAR (150)    NOT NULL,
    [Regions]     NVARCHAR (150) NULL);

