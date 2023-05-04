CREATE TABLE [MoneyGram].[EnumeratorCatalogGFFPConfigs] (
    [IdEnumeratorCatalogGFFPConfigs] INT           IDENTITY (1, 1) NOT NULL,
    [ReceiveCountry]                 VARCHAR (100) NULL,
    [DeliveryOption]                 VARCHAR (100) NULL,
    [ThirdPartyType]                 VARCHAR (100) NULL,
    [ReceiveCurrency]                VARCHAR (100) NULL,
    [Amount]                         MONEY         NULL,
    [SendCurrency]                   VARCHAR (100) NULL,
    [CreationDate]                   DATETIME      NOT NULL,
    [EnterByIdUser]                  INT           NOT NULL,
    CONSTRAINT [PK_MoneyGramEnumeratorCatalogGFFPConfigs] PRIMARY KEY CLUSTERED ([IdEnumeratorCatalogGFFPConfigs] ASC)
);

