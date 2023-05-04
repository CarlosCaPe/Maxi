CREATE TABLE [dbo].[BancoUnionLogFileTXT] (
    [IdBancoUnionLogFileTXT] INT            IDENTITY (1, 1) NOT NULL,
    [IdTransfer]             INT            NOT NULL,
    [FileName]               VARCHAR (50)   NOT NULL,
    [DateOfFileCreation]     DATETIME       NOT NULL,
    [TypeOfTransfer]         NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_BancoUnionLogFileTXT] PRIMARY KEY CLUSTERED ([IdBancoUnionLogFileTXT] ASC)
);

