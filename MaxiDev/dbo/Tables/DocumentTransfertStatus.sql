CREATE TABLE [dbo].[DocumentTransfertStatus] (
    [IdStatus] INT            NOT NULL,
    [Name]     NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_DocumentTransfertStatus] PRIMARY KEY CLUSTERED ([IdStatus] ASC)
);

