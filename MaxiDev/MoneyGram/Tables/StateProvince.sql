CREATE TABLE [MoneyGram].[StateProvince] (
    [CountryCode]       VARCHAR (10)  NOT NULL,
    [StateProvinceCode] VARCHAR (10)  NOT NULL,
    [StateProvinceName] VARCHAR (200) NULL,
    [DateOfLastChange]  DATETIME      NULL,
    [CreationDate]      DATETIME      NOT NULL,
    CONSTRAINT [PK_MoneyGramStateProvince] PRIMARY KEY CLUSTERED ([CountryCode] ASC, [StateProvinceCode] ASC),
    CONSTRAINT [FK_MoneyGramStateProvince_MoneyGramCountry] FOREIGN KEY ([CountryCode]) REFERENCES [MoneyGram].[Country] ([CountryCode])
);

