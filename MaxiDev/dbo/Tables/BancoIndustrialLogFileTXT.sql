CREATE TABLE [dbo].[BancoIndustrialLogFileTXT] (
    [IdBancoIndustrialLogFileTXT] INT            IDENTITY (1, 1) NOT NULL,
    [IdTransfer]                  INT            NOT NULL,
    [IdFileName]                  INT            NOT NULL,
    [DateOfFileCreation]          DATETIME       NOT NULL,
    [TypeOfTransfer]              NVARCHAR (MAX) NOT NULL
);


GO
CREATE CLUSTERED INDEX [ClusteredIndex-20161213-100928]
    ON [dbo].[BancoIndustrialLogFileTXT]([IdTransfer] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_BancoIndustrialLogFileTXT_IdFileName]
    ON [dbo].[BancoIndustrialLogFileTXT]([IdFileName] ASC)
    INCLUDE([IdTransfer], [DateOfFileCreation], [TypeOfTransfer]);

