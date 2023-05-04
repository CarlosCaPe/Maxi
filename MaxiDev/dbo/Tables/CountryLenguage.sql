CREATE TABLE [dbo].[CountryLenguage] (
    [IdCountryLenguage] INT IDENTITY (1, 1) NOT NULL,
    [IdCountry]         INT NULL,
    [IdLenguage]        INT NULL,
    CONSTRAINT [PK_CountryLenguage] PRIMARY KEY CLUSTERED ([IdCountryLenguage] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_CountryLenguage_Country] FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[Country] ([IdCountry]),
    CONSTRAINT [FK_CountryLenguage_Lenguage] FOREIGN KEY ([IdLenguage]) REFERENCES [dbo].[Lenguage] ([IdLenguage])
);

