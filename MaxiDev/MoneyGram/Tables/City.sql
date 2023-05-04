CREATE TABLE [MoneyGram].[City] (
    [IdCity]            INT           IDENTITY (1, 1) NOT NULL,
    [CountryCode]       VARCHAR (10)  NOT NULL,
    [StateProvinceCode] VARCHAR (10)  NULL,
    [CityName]          VARCHAR (200) NOT NULL,
    [DateOfLastChange]  DATETIME      NULL,
    [CreationDate]      DATETIME      NOT NULL,
    [Active]            BIT           NOT NULL,
    CONSTRAINT [PK_MoneyGramCity] PRIMARY KEY CLUSTERED ([IdCity] ASC),
    CONSTRAINT [FK_MoneyGramCity_MoneyGramCountry] FOREIGN KEY ([CountryCode]) REFERENCES [MoneyGram].[Country] ([CountryCode]),
    CONSTRAINT [FK_MoneyGramCity_StateProvince] FOREIGN KEY ([CountryCode], [StateProvinceCode]) REFERENCES [MoneyGram].[StateProvince] ([CountryCode], [StateProvinceCode]),
    CONSTRAINT [UQ_MoneyGramCity] UNIQUE NONCLUSTERED ([CountryCode] ASC, [StateProvinceCode] ASC, [CityName] ASC)
);

