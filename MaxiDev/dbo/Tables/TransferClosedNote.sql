CREATE TABLE [dbo].[TransferClosedNote] (
    [IdTransferClosedNote]   INT           NOT NULL,
    [IdTransferClosedDetail] INT           NOT NULL,
    [IdTransferNoteType]     INT           NOT NULL,
    [IdUser]                 INT           NOT NULL,
    [Note]                   VARCHAR (MAX) NOT NULL,
    [EnterDate]              DATETIME      NOT NULL,
    CONSTRAINT [PK_TransferClosedNote] PRIMARY KEY CLUSTERED ([IdTransferClosedNote] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_TransferClosedNote_TransferClosedDetail] FOREIGN KEY ([IdTransferClosedDetail]) REFERENCES [dbo].[TransferClosedDetail] ([IdTransferClosedDetail]),
    CONSTRAINT [FK_TransferClosedNote_TransferNoteType] FOREIGN KEY ([IdTransferNoteType]) REFERENCES [dbo].[TransferNoteType] ([IdTransferNoteType]),
    CONSTRAINT [FK_TransferClosedNote_Users] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IdxIdTransferClosedDetail]
    ON [dbo].[TransferClosedNote]([IdTransferClosedDetail] ASC) WITH (FILLFACTOR = 90);

