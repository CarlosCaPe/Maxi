CREATE TABLE [TransFerTo].[Currency] (
    [IdCurrency]       INT          IDENTITY (1, 1) NOT NULL,
    [CurrencyName]     NVARCHAR (3) NOT NULL,
    [DateOfCreation]   DATETIME     NOT NULL,
    [DateOfLastChange] DATETIME     NOT NULL,
    [EnterByIdUser]    INT          NOT NULL,
    CONSTRAINT [PK_TransferTToCurrency] PRIMARY KEY CLUSTERED ([IdCurrency] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_TToCurrency_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

