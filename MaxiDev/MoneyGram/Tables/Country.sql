CREATE TABLE [MoneyGram].[Country] (
    [CountryCode]           VARCHAR (10)  NOT NULL,
    [CountryName]           VARCHAR (200) NOT NULL,
    [CountryLegacyCode]     VARCHAR (10)  NULL,
    [SendActive]            BIT           NOT NULL,
    [ReceiveActive]         BIT           NOT NULL,
    [DirectedSendCountry]   BIT           NOT NULL,
    [MgDirectedSendCountry] BIT           NOT NULL,
    [BaseReceiveCurrency]   VARCHAR (10)  NULL,
    [IsZipCodeRequired]     BIT           NULL,
    [DateOfLastChange]      DATETIME      NULL,
    [CreationDate]          DATETIME      NOT NULL,
    [ActiveForMaxi]         BIT           CONSTRAINT [DF_MoneyGramCountry_ActiveForMaxi] DEFAULT ((1)) NOT NULL,
    [IdPayerConfig]         INT           NULL,
    [IsStateRequired]       BIT           CONSTRAINT [DF_MoneyGramCountry_IsStateRequired] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_MoneyGram_Country] PRIMARY KEY CLUSTERED ([CountryCode] ASC),
    CONSTRAINT [FK_MoneyGramCountry_MoneyGramCurrency] FOREIGN KEY ([BaseReceiveCurrency]) REFERENCES [MoneyGram].[Currency] ([CurrencyCode]),
    CONSTRAINT [FK_MoneyGramCountry_PayerConfig_IdPayerConfig] FOREIGN KEY ([IdPayerConfig]) REFERENCES [dbo].[PayerConfig] ([IdPayerConfig])
);

