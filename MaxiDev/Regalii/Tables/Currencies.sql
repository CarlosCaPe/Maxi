CREATE TABLE [Regalii].[Currencies] (
    [Currency]   VARCHAR (5) NOT NULL,
    [Exchange]   MONEY       NOT NULL,
    [IdCurrency] INT         NULL,
    CONSTRAINT [PK_Currencies] PRIMARY KEY CLUSTERED ([Currency] ASC)
);

