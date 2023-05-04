CREATE TABLE [dbo].[PosTransfer] (
    [IdPosTransfer]    INT            IDENTITY (1, 1) NOT NULL,
    [IdTransfer]       INT            NULL,
    [IdTransferClosed] INT            NULL,
    [AuthorizationNo]  NVARCHAR (10)  NOT NULL,
    [BatchNo]          NVARCHAR (100) NOT NULL,
    [ReferenceNo]      NVARCHAR (100) NOT NULL,
    [TerminalId]       NVARCHAR (100) NOT NULL,
    [MerchantId]       NVARCHAR (100) NOT NULL,
    [AccountNo]        NVARCHAR (100) NOT NULL,
    [IdPosStatus]      SMALLINT       NOT NULL,
    [IdCardEntryMode]  SMALLINT       NOT NULL,
    [IdCardType]       SMALLINT       NOT NULL,
    [IdPosActionType]  INT            NOT NULL,
    [CreationDate]     DATETIME       NULL,
    [IdUser]           INT            NULL,
    CONSTRAINT [PK_PosTransfer] PRIMARY KEY CLUSTERED ([IdPosTransfer] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_PosTransfer_Transfer] FOREIGN KEY ([IdTransfer]) REFERENCES [dbo].[Transfer] ([IdTransfer]),
    CONSTRAINT [FK_PosTransfer_TransferClosed] FOREIGN KEY ([IdTransferClosed]) REFERENCES [dbo].[TransferClosed] ([IdTransferClosed]),
    CONSTRAINT [FK_PosTransfer_User] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

