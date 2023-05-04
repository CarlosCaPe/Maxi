CREATE TABLE [OfacAudit].[OfacAuditReview] (
    [IdOfacAuditReview] INT      IDENTITY (1, 1) NOT NULL,
    [IdOfacAuditDetail] INT      NULL,
    [IdUserReview]      INT      NULL,
    [DateOfReview]      DATETIME NULL,
    [IdOFACAction]      INT      NULL,
    CONSTRAINT [PK_OfacAuditReview] PRIMARY KEY CLUSTERED ([IdOfacAuditReview] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_OfacAuditReview_ofacauditdetail] FOREIGN KEY ([IdOfacAuditDetail]) REFERENCES [dbo].[OfacAuditDetail] ([IdOfacAuditDetail]),
    CONSTRAINT [FK_OfacAuditReview_Users1] FOREIGN KEY ([IdUserReview]) REFERENCES [dbo].[Users] ([IdUser])
);

