CREATE TABLE [Regalii].[CountryMap] (
    [CountryCode]        VARCHAR (50)  NOT NULL,
    [RegaliiCountryName] VARCHAR (50)  NOT NULL,
    [PhoneCode]          VARCHAR (50)  NOT NULL,
    [PhoneLenght]        VARCHAR (500) NULL,
    CONSTRAINT [PK_Country_2] PRIMARY KEY CLUSTERED ([CountryCode] ASC)
);

