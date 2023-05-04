CREATE TABLE [MoneyGram].[Currency] (
    [CurrencyCode]      VARCHAR (10)  NOT NULL,
    [CurrencyName]      VARCHAR (200) NOT NULL,
    [CurrencyPrecision] INT           NOT NULL,
    [DateOfLastChange]  DATETIME      NULL,
    [CreationDate]      DATETIME      NOT NULL,
    CONSTRAINT [PK_MoneyGram_Currency] PRIMARY KEY CLUSTERED ([CurrencyCode] ASC)
);

