CREATE TABLE [dbo].[BankDeposit] (
    [IdBankDeposit]     INT            IDENTITY (1, 1) NOT NULL,
    [IdBankDepositFile] INT            NOT NULL,
    [DepositDate]       DATETIME       NOT NULL,
    [Description]       VARCHAR (200)  NOT NULL,
    [Amount]            MONEY          NOT NULL,
    [Sign]              INT            NULL,
    [Reference]         VARCHAR (200)  NULL,
    [Details]           VARCHAR (1000) NULL,
    [TransactionDate]   DATETIME       NOT NULL,
    CONSTRAINT [PK_BankDeposit] PRIMARY KEY CLUSTERED ([IdBankDeposit] ASC),
    CONSTRAINT [FK_BankDeposit_BankDepositFile] FOREIGN KEY ([IdBankDepositFile]) REFERENCES [dbo].[BankDepositFile] ([IdBankDepositFile])
);

