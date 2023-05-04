CREATE TABLE [dbo].[AriasResponseLog] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [fecha]          DATETIME       NULL,
    [claimcode]      NVARCHAR (MAX) NULL,
    [ReturnCode]     NVARCHAR (MAX) NULL,
    [ReturnCodeType] INT            NULL,
    [IdStatus]       INT            NULL,
    [Description]    NVARCHAR (MAX) NULL,
    [XMLResponse]    XML            NULL
);

