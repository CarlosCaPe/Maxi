CREATE TABLE [dbo].[Country] (
    [IdCountry]          INT            IDENTITY (1, 1) NOT NULL,
    [CountryName]        NVARCHAR (MAX) NOT NULL,
    [CountryCode]        NVARCHAR (MAX) NULL,
    [DateOfLastChange]   DATETIME       NOT NULL,
    [EnterByIdUser]      INT            NOT NULL,
    [CountryFlag]        NVARCHAR (MAX) NULL,
    [CountryCodeISO3166] NVARCHAR (2)   NULL,
    CONSTRAINT [PK_Country] PRIMARY KEY CLUSTERED ([IdCountry] ASC) WITH (FILLFACTOR = 90)
);

