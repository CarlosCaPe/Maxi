CREATE TABLE [moneyalert].[CountryPhoneCode] (
    [IdCountryPhoneCode] INT IDENTITY (1, 1) NOT NULL,
    [IdCountry]          INT NOT NULL,
    [CountryPhoneCode]   INT NOT NULL,
    CONSTRAINT [PK_CountryPhoneCode_1] PRIMARY KEY CLUSTERED ([IdCountryPhoneCode] ASC)
);

