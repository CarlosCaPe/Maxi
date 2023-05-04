CREATE TABLE [dbo].[TransferNoteNotification] (
    [IdTransferNoteNotification] INT IDENTITY (1, 1) NOT NULL,
    [IdTransferNote]             INT NOT NULL,
    [IdMessage]                  INT NULL,
    [IdGenericStatus]            INT NOT NULL,
    CONSTRAINT [PK_TransferNoteNotification] PRIMARY KEY CLUSTERED ([IdTransferNoteNotification] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_TransferNoteNotification_TransferNote] FOREIGN KEY ([IdTransferNote]) REFERENCES [dbo].[TransferNote] ([IdTransferNote])
);


GO
CREATE NONCLUSTERED INDEX [ix_TransferNoteNotification_IdTransferNote_IdGenericStatus_includes]
    ON [dbo].[TransferNoteNotification]([IdGenericStatus] ASC)
    INCLUDE([IdMessage], [IdTransferNote]);


GO
CREATE NONCLUSTERED INDEX [IX_TransferNoteNotification_IdMessage]
    ON [dbo].[TransferNoteNotification]([IdMessage] ASC)
    INCLUDE([IdTransferNote]);


GO
CREATE NONCLUSTERED INDEX [IX_TransferNoteNotification_IdTransferNote_IdGenericStatus]
    ON [dbo].[TransferNoteNotification]([IdTransferNote] ASC, [IdGenericStatus] ASC)
    INCLUDE([IdMessage]);

