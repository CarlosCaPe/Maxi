CREATE TABLE [dbo].[TransferClosedDetail] (
    [IdTransferClosedDetail] INT      NOT NULL,
    [IdStatus]               INT      NULL,
    [IdTransferClosed]       INT      NOT NULL,
    [DateOfMovement]         DATETIME NOT NULL,
    CONSTRAINT [PK_TransferClosedDetail] PRIMARY KEY CLUSTERED ([IdTransferClosedDetail] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [idxIdStatusDOM]
    ON [dbo].[TransferClosedDetail]([IdStatus] ASC, [DateOfMovement] ASC)
    INCLUDE([IdTransferClosed]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [idxIdTransferClosed]
    ON [dbo].[TransferClosedDetail]([IdTransferClosed] ASC)
    INCLUDE([IdTransferClosedDetail], [IdStatus], [DateOfMovement]) WITH (FILLFACTOR = 90);

