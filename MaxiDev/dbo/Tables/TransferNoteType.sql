CREATE TABLE [dbo].[TransferNoteType] (
    [IdTransferNoteType] INT           NOT NULL,
    [TranferNoteType]    VARCHAR (MAX) NULL,
    CONSTRAINT [PK_TransferNoteType] PRIMARY KEY CLUSTERED ([IdTransferNoteType] ASC) WITH (FILLFACTOR = 90)
);

