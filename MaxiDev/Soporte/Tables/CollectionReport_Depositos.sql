CREATE TABLE [Soporte].[CollectionReport_Depositos] (
    [DepositDate]   DATETIME      NULL,
    [Agent]         VARCHAR (MAX) NULL,
    [Amount]        MONEY         NULL,
    [Notes]         VARCHAR (MAX) NULL,
    [Entry]         DATETIME      NULL,
    [BankName]      VARCHAR (MAX) NULL,
    [UserName]      VARCHAR (MAX) NULL,
    [MoveType]      VARCHAR (250) NULL,
    [DebitOrCredit] VARCHAR (250) NULL
);

