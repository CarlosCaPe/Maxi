CREATE TABLE [dbo].[TransferClosedHolds] (
    [IdTransferClosedHold] INT      IDENTITY (1, 1) NOT NULL,
    [IdTransferClosed]     INT      NOT NULL,
    [IdStatus]             INT      NOT NULL,
    [IsReleased]           BIT      NULL,
    [DateOfValidation]     DATETIME NOT NULL,
    [DateOfLastChange]     DATETIME NOT NULL,
    [EnterByIdUser]        INT      NOT NULL,
    CONSTRAINT [PK_TransferClosedHold] PRIMARY KEY CLUSTERED ([IdTransferClosedHold] ASC),
    CONSTRAINT [FK_TransferClosedHold_Status] FOREIGN KEY ([IdStatus]) REFERENCES [dbo].[Status] ([IdStatus]),
    CONSTRAINT [FK_TransferClosedHold_Transfer] FOREIGN KEY ([IdTransferClosed]) REFERENCES [dbo].[TransferClosed] ([IdTransferClosed])
);


GO
CREATE NONCLUSTERED INDEX [TransferClosedHolds_IdTransferClosedStatus]
    ON [dbo].[TransferClosedHolds]([IdTransferClosed] ASC, [IdStatus] ASC, [IsReleased] ASC);

