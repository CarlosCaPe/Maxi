CREATE TABLE [dbo].[TransferClosedNoteNotification] (
    [IdTransferClosedNoteNotification] INT NOT NULL,
    [IdTransferClosedNote]             INT NOT NULL,
    [IdMessage]                        INT NULL,
    [IdGenericStatus]                  INT NOT NULL,
    CONSTRAINT [PK_TransferClosedNoteNotification] PRIMARY KEY CLUSTERED ([IdTransferClosedNoteNotification] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_TransferClosedNoteNotification_TransferClosedNote] FOREIGN KEY ([IdTransferClosedNote]) REFERENCES [dbo].[TransferClosedNote] ([IdTransferClosedNote])
);


GO
CREATE NONCLUSTERED INDEX [IX_TransferClosedNoteNotification_IdTransferClosedNote]
    ON [dbo].[TransferClosedNoteNotification]([IdTransferClosedNote] ASC)
    INCLUDE([IdMessage], [IdGenericStatus]);


GO
CREATE NONCLUSTERED INDEX [IX_TransferClosedNoteNotification_IdMessage]
    ON [dbo].[TransferClosedNoteNotification]([IdMessage] ASC)
    INCLUDE([IdTransferClosedNote]);

