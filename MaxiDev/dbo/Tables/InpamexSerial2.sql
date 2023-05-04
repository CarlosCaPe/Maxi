CREATE TABLE [dbo].[InpamexSerial2] (
    [IdInpamexSerial] INT IDENTITY (1, 1) NOT NULL,
    [IdTransfer]      INT NOT NULL,
    CONSTRAINT [PK_InpamexSerial2] PRIMARY KEY CLUSTERED ([IdInpamexSerial] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_InpamexSerial2_IdTransfer]
    ON [dbo].[InpamexSerial2]([IdTransfer] ASC)
    INCLUDE([IdInpamexSerial]);

