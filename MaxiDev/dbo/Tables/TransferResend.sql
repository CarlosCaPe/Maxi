CREATE TABLE [dbo].[TransferResend] (
    [IdTransfer]       INT            NOT NULL,
    [Note]             VARCHAR (2000) NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    [NewIdTransfer]    INT            NULL,
    CONSTRAINT [PK_TransferResent] PRIMARY KEY CLUSTERED ([IdTransfer] ASC) WITH (FILLFACTOR = 90)
);

