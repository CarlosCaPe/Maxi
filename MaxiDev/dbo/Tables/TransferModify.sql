CREATE TABLE [dbo].[TransferModify] (
    [IdTransferModify] INT      IDENTITY (1, 1) NOT NULL,
    [OldIdTransfer]    INT      NULL,
    [NewIdTransfer]    INT      NULL,
    [CreatedBy]        INT      NULL,
    [CreateDate]       DATETIME NULL,
    [OldIdStatus]      INT      NULL,
    [IsCancel]         BIT      NULL,
    CONSTRAINT [Pk_TransferModify] PRIMARY KEY CLUSTERED ([IdTransferModify] ASC)
);

