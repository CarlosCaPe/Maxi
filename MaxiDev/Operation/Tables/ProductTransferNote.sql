CREATE TABLE [Operation].[ProductTransferNote] (
    [IdProductTransferNote]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [IdProductTransferDetail] BIGINT        NOT NULL,
    [IdTransferNoteType]      INT           NOT NULL,
    [IdUser]                  INT           NOT NULL,
    [Note]                    VARCHAR (MAX) NOT NULL,
    [EnterDate]               DATETIME      NOT NULL,
    CONSTRAINT [PK_ProductTransferNote] PRIMARY KEY CLUSTERED ([IdProductTransferNote] ASC),
    CONSTRAINT [FK_ProductTransferNote_ProductTransferDetail] FOREIGN KEY ([IdProductTransferDetail]) REFERENCES [Operation].[ProductTransferDetail] ([IdProductTransferDetail]),
    CONSTRAINT [FK_ProductTransferNote_TransferNoteType] FOREIGN KEY ([IdTransferNoteType]) REFERENCES [dbo].[TransferNoteType] ([IdTransferNoteType]),
    CONSTRAINT [FK_ProductTransferNote_Users] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

