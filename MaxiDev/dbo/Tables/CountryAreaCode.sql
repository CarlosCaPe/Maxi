CREATE TABLE [dbo].[CountryAreaCode] (
    [IdCountryAreaCode] INT IDENTITY (1, 1) NOT NULL,
    [IdCountry]         INT NULL,
    [AreaCode]          INT NULL,
    CONSTRAINT [PK_CountryAreaCode] PRIMARY KEY CLUSTERED ([IdCountryAreaCode] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_CountryAreaCode_Country] FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[Country] ([IdCountry])
);

