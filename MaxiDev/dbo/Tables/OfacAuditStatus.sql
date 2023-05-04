CREATE TABLE [dbo].[OfacAuditStatus] (
    [IdOfacAuditStatus] INT          NOT NULL,
    [Name]              VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_OfacAuditStatus] PRIMARY KEY CLUSTERED ([IdOfacAuditStatus] ASC) WITH (FILLFACTOR = 90)
);

