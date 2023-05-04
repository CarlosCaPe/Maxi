CREATE TABLE [dbo].[CountryPureMinutesTopUp] (
    [IdCountryPureMinutesTopUp] INT            NOT NULL,
    [CountryName]               NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_CountryPureMinutesTopUp] PRIMARY KEY CLUSTERED ([IdCountryPureMinutesTopUp] ASC) WITH (FILLFACTOR = 90)
);

