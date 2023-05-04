CREATE TABLE [dbo].[OfacAuditType] (
    [IdOfacAuditType] INT          NOT NULL,
    [Name]            VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_OfacAuditType] PRIMARY KEY CLUSTERED ([IdOfacAuditType] ASC) WITH (FILLFACTOR = 90)
);

