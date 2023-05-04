CREATE TABLE [dbo].[TransferNotAllowedResend] (
    [IdTransfer]       INT      NOT NULL,
    [DateOfLastChange] DATETIME NOT NULL,
    CONSTRAINT [PK_TransferNotAllowedResend] PRIMARY KEY CLUSTERED ([IdTransfer] ASC) WITH (FILLFACTOR = 90)
);

