CREATE TABLE [MaxiMobile].[CountryFlag] (
    [IdCountry]   INT            NOT NULL,
    [CountryFlag] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_CountryFlag] PRIMARY KEY CLUSTERED ([IdCountry] ASC) WITH (FILLFACTOR = 90)
);

