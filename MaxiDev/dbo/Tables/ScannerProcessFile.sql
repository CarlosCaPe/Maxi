CREATE TABLE [dbo].[ScannerProcessFile] (
    [IdScannerProcessFiles] INT            IDENTITY (1, 1) NOT NULL,
    [IdAgent]               INT            NOT NULL,
    [IdUploadFile]          INT            NOT NULL,
    [BankName]              NVARCHAR (MAX) NULL,
    [Amount]                MONEY          NULL,
    [EnterByIdUser]         INT            NULL,
    [DepositDate]           DATETIME       NULL,
    [CreationDate]          DATETIME       NULL,
    [DateofLastChange]      DATETIME       NULL,
    [IsProcessed]           BIT            NULL,
    CONSTRAINT [PK_ScannerProcessFile] PRIMARY KEY CLUSTERED ([IdScannerProcessFiles] ASC),
    CONSTRAINT [FK_ScannerProcessFile_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_ScannerProcessFile_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [ix_ScannerProcessFile_CreationDate_IsProcessed]
    ON [dbo].[ScannerProcessFile]([CreationDate] ASC, [IsProcessed] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ScannerProcessFile_IdUploadFile]
    ON [dbo].[ScannerProcessFile]([IdUploadFile] ASC);

