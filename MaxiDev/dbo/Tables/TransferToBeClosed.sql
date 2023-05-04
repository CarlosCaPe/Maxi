CREATE TABLE [dbo].[TransferToBeClosed] (
    [IdTransfer]      INT NULL,
    [IdOnWhoseBehalf] INT NULL
);


GO
CREATE NONCLUSTERED INDEX [idxTransfertobeclosed]
    ON [dbo].[TransferToBeClosed]([IdTransfer] ASC) WITH (FILLFACTOR = 90);

