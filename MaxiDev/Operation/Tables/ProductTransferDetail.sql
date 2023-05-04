CREATE TABLE [Operation].[ProductTransferDetail] (
    [IdProductTransferDetail] BIGINT   IDENTITY (1, 1) NOT NULL,
    [IdStatus]                INT      NULL,
    [IdProductTransfer]       BIGINT   NOT NULL,
    [DateOfMovement]          DATETIME NOT NULL,
    CONSTRAINT [PK_ProductTransferDetail] PRIMARY KEY CLUSTERED ([IdProductTransferDetail] ASC),
    CONSTRAINT [FK_ProductTransferDetail_ProductTransfer] FOREIGN KEY ([IdProductTransfer]) REFERENCES [Operation].[ProductTransfer] ([IdProductTransfer])
);


GO
CREATE NONCLUSTERED INDEX [IX_ProductTransferDetail_IdStatus_IdProductTransfer]
    ON [Operation].[ProductTransferDetail]([IdStatus] ASC, [IdProductTransfer] ASC)
    INCLUDE([IdProductTransferDetail], [DateOfMovement]);

