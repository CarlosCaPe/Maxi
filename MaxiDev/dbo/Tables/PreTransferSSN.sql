CREATE TABLE [dbo].[PreTransferSSN] (
    [IdPreTransfer]    INT      NOT NULL,
    [SSNRequired]      BIT      NOT NULL,
    [DateOfLastChange] DATETIME NOT NULL,
    CONSTRAINT [PK_PreTransferSSN] PRIMARY KEY CLUSTERED ([IdPreTransfer] ASC) WITH (FILLFACTOR = 90)
);

