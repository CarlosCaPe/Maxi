CREATE TABLE [dbo].[PendingFilesAgent] (
    [IdPendingFilesAgent] INT      IDENTITY (1, 1) NOT NULL,
    [IdAgent]             INT      NOT NULL,
    [IdDocumentType]      INT      NOT NULL,
    [ExpirationDate]      DATE     NULL,
    [IsUpload]            BIT      NOT NULL,
    [IdUserCreate]        INT      NOT NULL,
    [DateCreate]          DATETIME NULL,
    [IdUserLastChange]    INT      NOT NULL,
    [DateLastChange]      DATETIME NOT NULL,
    [IdGenericStatus]     INT      NOT NULL,
    [IdUploadFile]        INT      NULL,
    CONSTRAINT [PK_PendingFilesAgent] PRIMARY KEY CLUSTERED ([IdPendingFilesAgent] ASC),
    CONSTRAINT [FK_PendingFilesAgent_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_PendingFilesAgent_DocumentTypes] FOREIGN KEY ([IdDocumentType]) REFERENCES [dbo].[DocumentTypes] ([IdDocumentType]),
    CONSTRAINT [FK_PendingFilesAgent_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_PendingFilesAgent_UploadFiles] FOREIGN KEY ([IdUploadFile]) REFERENCES [dbo].[UploadFiles] ([IdUploadFile])
);


GO
CREATE NONCLUSTERED INDEX [IX_PendingFilesAgent_IdAgent_ExpirationDate_IsUpload_IdGenericStatus]
    ON [dbo].[PendingFilesAgent]([IdAgent] ASC, [ExpirationDate] ASC, [IsUpload] ASC, [IdGenericStatus] ASC, [IdDocumentType] ASC);

