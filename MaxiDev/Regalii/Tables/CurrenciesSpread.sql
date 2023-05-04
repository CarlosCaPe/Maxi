CREATE TABLE [Regalii].[CurrenciesSpread] (
    [IdCurrenciesSpread] INT      IDENTITY (1, 1) NOT NULL,
    [IdCurrency]         INT      NOT NULL,
    [IdAgent]            INT      NULL,
    [Spread]             MONEY    DEFAULT ((0)) NOT NULL,
    [IdGenericStatus]    INT      NOT NULL,
    [EnterByIdUser]      INT      NOT NULL,
    [DateOfLastChange]   DATETIME NULL,
    CONSTRAINT [PK_CurrenciesSpread] PRIMARY KEY CLUSTERED ([IdCurrenciesSpread] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_CurrenciesSpread_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_CurrenciesSpread_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_CurrenciesSpread_Users1] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

