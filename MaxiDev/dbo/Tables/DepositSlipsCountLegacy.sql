CREATE TABLE [dbo].[DepositSlipsCountLegacy] (
    [IdAgent]           INT            NOT NULL,
    [DepositSlipsCount] INT            NULL,
    [Amount]            MONEY          NULL,
    [Date]              DATE           NULL,
    [BankName]          NVARCHAR (MAX) NOT NULL
);

