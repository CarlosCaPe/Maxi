CREATE TABLE [dbo].[TransferHolds] (
    [IdTransferHold]   INT      IDENTITY (1, 1) NOT NULL,
    [IdTransfer]       INT      NOT NULL,
    [IdStatus]         INT      NOT NULL,
    [IsReleased]       BIT      NULL,
    [DateOfValidation] DATETIME NOT NULL,
    [DateOfLastChange] DATETIME NOT NULL,
    [EnterByIdUser]    INT      NOT NULL,
    CONSTRAINT [PK_TransferHold] PRIMARY KEY CLUSTERED ([IdTransferHold] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_TransferHold_Status] FOREIGN KEY ([IdStatus]) REFERENCES [dbo].[Status] ([IdStatus]),
    CONSTRAINT [FK_TransferHold_Transfer] FOREIGN KEY ([IdTransfer]) REFERENCES [dbo].[Transfer] ([IdTransfer])
);


GO
CREATE NONCLUSTERED INDEX [IX_TransferHolds_IdTransfer]
    ON [dbo].[TransferHolds]([IdTransfer] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [ix_TransferHolds_IdStatus_IsReleased_includes]
    ON [dbo].[TransferHolds]([IdStatus] ASC, [IsReleased] ASC)
    INCLUDE([IdTransfer], [IdTransferHold], [DateOfValidation]);

