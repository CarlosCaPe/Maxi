CREATE TABLE [dbo].[TTApiSerial] (
    [IdTransfer] INT NOT NULL,
    [Serial]     INT NULL,
    CONSTRAINT [PK_TTApiSerial] PRIMARY KEY CLUSTERED ([IdTransfer] ASC) WITH (FILLFACTOR = 90)
);

