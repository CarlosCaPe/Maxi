﻿CREATE TABLE [dbo].[InpamexResponseLog] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [fecha]          DATETIME       NULL,
    [claimcode]      NVARCHAR (MAX) NULL,
    [ReturnCode]     NVARCHAR (MAX) NULL,
    [ReturnCodeType] INT            NULL,
    [IdStatus]       INT            NULL,
    [Description]    NVARCHAR (MAX) NULL,
    [XMLResponse]    XML            NULL,
    CONSTRAINT [PK_InpamexResponseLog] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 90)
);

