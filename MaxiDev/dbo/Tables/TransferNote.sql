CREATE TABLE [dbo].[TransferNote] (
    [IdTransferNote]     INT           IDENTITY (1, 1) NOT NULL,
    [IdTransferDetail]   INT           NOT NULL,
    [IdTransferNoteType] INT           NOT NULL,
    [IdUser]             INT           NOT NULL,
    [Note]               VARCHAR (MAX) NOT NULL,
    [EnterDate]          DATETIME      NOT NULL,
    CONSTRAINT [PK_TransferNote] PRIMARY KEY CLUSTERED ([IdTransferNote] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_TransferNote_TransferDetail] FOREIGN KEY ([IdTransferDetail]) REFERENCES [dbo].[TransferDetail] ([IdTransferDetail]),
    CONSTRAINT [FK_TransferNote_TransferNoteType] FOREIGN KEY ([IdTransferNoteType]) REFERENCES [dbo].[TransferNoteType] ([IdTransferNoteType]),
    CONSTRAINT [FK_TransferNote_Users] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IdxIdTransferDetail]
    ON [dbo].[TransferNote]([IdTransferDetail] ASC) WITH (FILLFACTOR = 90);

