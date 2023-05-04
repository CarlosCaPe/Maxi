CREATE TABLE [dbo].[OfacAuditDetail] (
    [IdOfacAuditDetail]  INT            IDENTITY (1, 1) NOT NULL,
    [IdOfacAudit]        INT            NOT NULL,
    [Name]               VARCHAR (200)  NOT NULL,
    [FirstLastName]      VARCHAR (200)  NOT NULL,
    [SecondLastName]     VARCHAR (200)  NOT NULL,
    [IdOfacAuditType]    INT            NOT NULL,
    [IdOfacAuditStatus]  INT            NOT NULL,
    [ChangeStatusIdUser] INT            NULL,
    [ChangeStatusNote]   VARCHAR (MAX)  NULL,
    [LastChangeDate]     DATETIME       NOT NULL,
    [LastChangeNote]     NVARCHAR (MAX) NOT NULL,
    [LastChangeIP]       NVARCHAR (50)  NOT NULL,
    [LastChangeIdUser]   INT            NULL,
    [AgentCode]          NVARCHAR (MAX) DEFAULT ('') NOT NULL,
    [IdGeneric]          INT            NULL,
    CONSTRAINT [PK_OfactAuditDetail] PRIMARY KEY CLUSTERED ([IdOfacAuditDetail] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_OfactAuditDetail_OfacAudit] FOREIGN KEY ([IdOfacAudit]) REFERENCES [dbo].[OfacAudit] ([IdOfacAudit]),
    CONSTRAINT [FK_OfactAuditDetail_OfacAuditStatus] FOREIGN KEY ([IdOfacAuditStatus]) REFERENCES [dbo].[OfacAuditStatus] ([IdOfacAuditStatus]),
    CONSTRAINT [FK_OfactAuditDetail_OfacAuditType] FOREIGN KEY ([IdOfacAuditType]) REFERENCES [dbo].[OfacAuditType] ([IdOfacAuditType]),
    CONSTRAINT [FK_OfactAuditDetail_Users] FOREIGN KEY ([ChangeStatusIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [ix_OfacAuditDetail_IdGeneric_IdOfacAuditType]
    ON [dbo].[OfacAuditDetail]([IdGeneric] ASC, [IdOfacAuditType] ASC);

