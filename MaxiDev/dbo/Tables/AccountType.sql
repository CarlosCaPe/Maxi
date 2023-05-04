CREATE TABLE [dbo].[AccountType] (
    [AccountTypeId]   INT            IDENTITY (1, 1) NOT NULL,
    [AccountTypeName] NVARCHAR (MAX) NOT NULL,
    [InserteredDate]  DATETIME       NOT NULL,
    PRIMARY KEY CLUSTERED ([AccountTypeId] ASC)
);

