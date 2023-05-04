CREATE TABLE [dbo].[TransferDetail] (
    [IdTransferDetail] INT      IDENTITY (1, 1) NOT NULL,
    [IdStatus]         INT      NULL,
    [IdTransfer]       INT      NOT NULL,
    [DateOfMovement]   DATETIME NOT NULL,
    CONSTRAINT [PK_TransferDetail] PRIMARY KEY CLUSTERED ([IdTransferDetail] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_TransferDetail_Transfer] FOREIGN KEY ([IdTransfer]) REFERENCES [dbo].[Transfer] ([IdTransfer])
);


GO
CREATE NONCLUSTERED INDEX [IDX_TransferDetail_IdTransfer]
    ON [dbo].[TransferDetail]([IdTransfer] ASC)
    INCLUDE([IdTransferDetail], [IdStatus], [DateOfMovement]);


GO
CREATE NONCLUSTERED INDEX [IX_TransferDetail_IdStatus_DateOfMovement]
    ON [dbo].[TransferDetail]([IdStatus] ASC, [DateOfMovement] ASC)
    INCLUDE([IdTransfer]);

