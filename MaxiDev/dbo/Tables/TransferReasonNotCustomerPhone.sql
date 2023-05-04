CREATE TABLE [dbo].[TransferReasonNotCustomerPhone] (
    [IdTransferReasonNotCustomerPhone] INT            IDENTITY (1, 1) NOT NULL,
    [IdPreTransfer]                    INT            NULL,
    [IdTransfer]                       INT            NULL,
    [IdReasonNotCustomerCellphone]     INT            NOT NULL,
    [NoteReasonNotCustomerPhone]       NVARCHAR (500) NULL,
    [EnterByIdUser]                    INT            NULL,
    [CreationDate]                     DATETIME       DEFAULT (getdate()) NOT NULL,
    [DateOfLastChange]                 DATETIME       DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([IdTransferReasonNotCustomerPhone] ASC, [IdReasonNotCustomerCellphone] ASC),
    FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser]),
    FOREIGN KEY ([IdPreTransfer]) REFERENCES [dbo].[PreTransfer] ([IdPreTransfer]),
    FOREIGN KEY ([IdTransfer]) REFERENCES [dbo].[Transfer] ([IdTransfer]),
    FOREIGN KEY ([IdTransfer]) REFERENCES [dbo].[Transfer] ([IdTransfer])
);

