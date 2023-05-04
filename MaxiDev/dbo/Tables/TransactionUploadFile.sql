CREATE TABLE [dbo].[TransactionUploadFile] (
    [IdTransactionUploadFile] INT            IDENTITY (1, 1) NOT NULL,
    [IdTransfer]              INT            NOT NULL,
    [FolderName]              NVARCHAR (100) NOT NULL,
    [FileName]                NVARCHAR (100) NOT NULL,
    [FileType]                NVARCHAR (10)  NOT NULL,
    CONSTRAINT [PK_TransactionUploadFile] PRIMARY KEY CLUSTERED ([IdTransactionUploadFile] ASC)
);

