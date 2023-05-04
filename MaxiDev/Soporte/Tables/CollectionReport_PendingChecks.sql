CREATE TABLE [Soporte].[CollectionReport_PendingChecks] (
    [Entry]         DATETIME      NULL,
    [Agent]         VARCHAR (MAX) NULL,
    [Amount]        MONEY         NULL,
    [Notes]         VARCHAR (MAX) NULL,
    [Date]          DATETIME      NULL,
    [BankName]      VARCHAR (MAX) NULL,
    [UserName]      VARCHAR (MAX) NULL,
    [MoveType]      VARCHAR (250) NULL,
    [DebitOrCredit] VARCHAR (250) NULL
);

