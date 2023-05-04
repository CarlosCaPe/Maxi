CREATE TABLE [MoneyGram].[Credentials] (
    [IdCredentials] INT           IDENTITY (1, 1) NOT NULL,
    [CurrencyCode]  VARCHAR (10)  NULL,
    [AgentID]       VARCHAR (200) NOT NULL,
    [AgentSecuence] VARCHAR (200) NOT NULL,
    [Token]         VARCHAR (200) NOT NULL,
    [BaseURL]       VARCHAR (200) NOT NULL,
    [APIVersion]    VARCHAR (200) NOT NULL,
    CONSTRAINT [PK_MoneyGramCredentials] PRIMARY KEY CLUSTERED ([IdCredentials] ASC),
    CONSTRAINT [FK_MoneyGramCredentials_MoneyGramCurrency_CurrencyCode] FOREIGN KEY ([CurrencyCode]) REFERENCES [MoneyGram].[Currency] ([CurrencyCode]),
    CONSTRAINT [UQ_MoneyGramCredentials_AgentID] UNIQUE NONCLUSTERED ([AgentID] ASC)
);

