CREATE TABLE [moneyalert].[StoreProcedureUsage] (
    [IdStoreProcedureUsage] INT             IDENTITY (1, 1) NOT NULL,
    [StoreProcedureName]    NVARCHAR (2000) NULL,
    [DateOfInsert]          DATETIME        NULL,
    [IdGeneric]             INT             NULL,
    CONSTRAINT [PK_StoreProcedureUsage] PRIMARY KEY CLUSTERED ([IdStoreProcedureUsage] ASC) WITH (FILLFACTOR = 90)
);

