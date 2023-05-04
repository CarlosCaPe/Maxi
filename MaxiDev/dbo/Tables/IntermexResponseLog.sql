CREATE TABLE [dbo].[IntermexResponseLog] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [Date]           DATETIME       NULL,
    [ClaimCode]      NVARCHAR (MAX) NULL,
    [ReturnCode]     NVARCHAR (MAX) NULL,
    [ReturnCodeType] INT            NULL,
    [IdStatus]       INT            NULL,
    [Description]    NVARCHAR (MAX) NULL,
    [XMLResponse]    XML            NULL,
    CONSTRAINT [PK_IntermexResponseLog] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 90)
);

