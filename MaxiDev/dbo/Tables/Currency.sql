CREATE TABLE [dbo].[Currency] (
    [IdCurrency]          INT            IDENTITY (1, 1) NOT NULL,
    [CurrencyName]        NVARCHAR (MAX) NOT NULL,
    [CurrencyCode]        NVARCHAR (MAX) NULL,
    [DateOfLastChange]    DATETIME       NOT NULL,
    [EnterByIdUser]       INT            NOT NULL,
    [DivisorExchangeRate] DECIMAL (4, 2) NOT NULL,
    CONSTRAINT [PK_Currency] PRIMARY KEY CLUSTERED ([IdCurrency] ASC) WITH (FILLFACTOR = 90)
);

