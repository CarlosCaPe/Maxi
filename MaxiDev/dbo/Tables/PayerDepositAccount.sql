CREATE TABLE [dbo].[PayerDepositAccount] (
    [IdPayerDepositAccunt] INT      IDENTITY (1, 1) NOT NULL,
    [IdPayer]              INT      NOT NULL,
    [ValidAccountLength]   INT      NOT NULL,
    [LastChange]           DATETIME NOT NULL,
    [IdUser]               INT      NOT NULL,
    CONSTRAINT [PK_PayerDepositAccount] PRIMARY KEY CLUSTERED ([IdPayerDepositAccunt] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_PayerDepositAccount_Payer] FOREIGN KEY ([IdPayer]) REFERENCES [dbo].[Payer] ([IdPayer])
);

