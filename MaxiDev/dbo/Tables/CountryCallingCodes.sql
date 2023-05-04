CREATE TABLE [dbo].[CountryCallingCodes] (
    [IdCountryCallingCode] INT          IDENTITY (1, 1) NOT NULL,
    [CountryCodeAlpha2]    VARCHAR (10) NOT NULL,
    [CountryCodeAlpha3]    VARCHAR (10) NOT NULL,
    [ISD]                  VARCHAR (10) NOT NULL,
    CONSTRAINT [PK_CountryCallingCodes] PRIMARY KEY CLUSTERED ([IdCountryCallingCode] ASC)
);

