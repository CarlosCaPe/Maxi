CREATE TABLE [dbo].[TToMobileResponseLog] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [Date]           DATETIME       NULL,
    [ClaimCode]      NVARCHAR (MAX) NULL,
    [ReturnCode]     NVARCHAR (MAX) NULL,
    [ReturnCodeType] INT            NULL,
    [IdStatus]       INT            NULL,
    [Description]    NVARCHAR (MAX) NULL,
    [XMLResponse]    XML            NULL
);

