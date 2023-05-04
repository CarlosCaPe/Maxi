CREATE TABLE [dbo].[InpamexSerial] (
    [IdInpamexSerial] INT IDENTITY (1, 1) NOT NULL,
    [IdTransfer]      INT NOT NULL,
    CONSTRAINT [PK_InpamexSerial] PRIMARY KEY CLUSTERED ([IdInpamexSerial] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_InpamexSerial_IdTransfer]
    ON [dbo].[InpamexSerial]([IdTransfer] ASC)
    INCLUDE([IdInpamexSerial]);

