CREATE TABLE [dbo].[RelationTransferDocumentStatus] (
    [IdRelationTransferDocumentStatus] INT      IDENTITY (1, 1) NOT NULL,
    [IdTransfer]                       INT      NOT NULL,
    [IdDocumentTransfertStatus]        INT      NOT NULL,
    [IdUserCreate]                     INT      NOT NULL,
    [DateCreate]                       DATETIME NOT NULL,
    [IdUserLastChange]                 INT      NOT NULL,
    [DateLastChange]                   DATETIME NOT NULL,
    [IsTransferReceipt]                BIT      CONSTRAINT [DF_RelationTransferDocumentStatus_IsTransferReceipt] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_RelationTransferDocumentStatus] PRIMARY KEY CLUSTERED ([IdRelationTransferDocumentStatus] ASC),
    CONSTRAINT [FK_RelationTransferDocumentStatus_Users] FOREIGN KEY ([IdUserCreate]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [FK_RelationTransferDocumentStatus_Users1] FOREIGN KEY ([IdUserLastChange]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IX_RelationTransferDocumentStatus_IdTransfer]
    ON [dbo].[RelationTransferDocumentStatus]([IdTransfer] ASC)
    INCLUDE([IdDocumentTransfertStatus]);

