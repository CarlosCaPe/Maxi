﻿CREATE TABLE [dbo].[KYCActor] (
    [IdActor] INT            IDENTITY (1, 1) NOT NULL,
    [Name]    NVARCHAR (50)  NOT NULL,
    [Display] NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_KYCActor] PRIMARY KEY CLUSTERED ([IdActor] ASC) WITH (FILLFACTOR = 90)
);

