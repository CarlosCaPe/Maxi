CREATE TABLE [MoneyGram].[CountryCurrency] (
    [CountryCode]              VARCHAR (10) NOT NULL,
    [BaseCurrency]             VARCHAR (10) NOT NULL,
    [LocalCurrency]            VARCHAR (10) NULL,
    [ReceiveCurrency]          VARCHAR (10) NOT NULL,
    [IndicativeRateAvailable]  BIT          NOT NULL,
    [DeliveryOption]           VARCHAR (30) NULL,
    [ReceiveAgentID]           VARCHAR (10) NULL,
    [ReceiveAgentAbbreviation] VARCHAR (10) NULL,
    [MgManaged]                VARCHAR (20) NULL,
    [AgentManaged]             VARCHAR (20) NULL,
    [ValidationExprs]          VARCHAR (20) NULL,
    [CheckDigitAlg]            VARCHAR (20) NULL,
    [DateOfLastChange]         DATETIME     NULL,
    [CreationDate]             DATETIME     NOT NULL,
    [ActiveForMaxi]            BIT          CONSTRAINT [DF_MoneyGramCountryCurrency_ActiveForMaxi] DEFAULT ((1)) NOT NULL
);

