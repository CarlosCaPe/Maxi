CREATE TABLE [OfacAudit].[OfacAuditMatchReview] (
    [IdOfacAuditMatchReview] INT             IDENTITY (1, 1) NOT NULL,
    [IdOfacAuditDetail]      INT             NULL,
    [SDN_NAME]               NVARCHAR (4000) NULL,
    [DateOfReview]           DATETIME        NULL,
    CONSTRAINT [PK_IdOfacAuditMatchReview] PRIMARY KEY CLUSTERED ([IdOfacAuditMatchReview] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_OfacAuditMatchReview_ofacauditdetail] FOREIGN KEY ([IdOfacAuditDetail]) REFERENCES [dbo].[OfacAuditDetail] ([IdOfacAuditDetail])
);

