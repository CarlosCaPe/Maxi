CREATE TABLE [dbo].[OfacAudit] (
    [IdOfacAudit]   INT      IDENTITY (1, 1) NOT NULL,
    [ExecutionDate] DATETIME NOT NULL,
    [IdUser]        INT      NULL,
    CONSTRAINT [PK_OfacAudit] PRIMARY KEY CLUSTERED ([IdOfacAudit] ASC) WITH (FILLFACTOR = 90)
);

