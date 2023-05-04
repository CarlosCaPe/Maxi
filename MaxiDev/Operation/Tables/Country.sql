CREATE TABLE [Operation].[Country] (
    [IdCountry]       INT            IDENTITY (1, 1) NOT NULL,
    [EnteredByIdUser] INT            NOT NULL,
    [IdGenericStatus] INT            NOT NULL,
    [CountryName]     NVARCHAR (100) NOT NULL,
    [CountryISOCode]  NVARCHAR (20)  NULL,
    CONSTRAINT [PK_Country_1] PRIMARY KEY CLUSTERED ([IdCountry] ASC)
);

