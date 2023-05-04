CREATE TABLE [dbo].[TransferSSN] (
    [IdTransfer]       INT      NOT NULL,
    [SSNRequired]      BIT      NOT NULL,
    [DateOfLastChange] DATETIME NOT NULL,
    CONSTRAINT [PK_TransferSSN] PRIMARY KEY CLUSTERED ([IdTransfer] ASC) WITH (FILLFACTOR = 90)
);

