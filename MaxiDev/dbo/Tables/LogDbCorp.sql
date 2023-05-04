﻿CREATE TABLE [dbo].[LogDbCorp] (
    [IdLogDB]  INT            IDENTITY (1, 1) NOT NULL,
    [IdUser]   INT            NULL,
    [Request]  NVARCHAR (MAX) NULL,
    [Response] NVARCHAR (MAX) NULL,
    [Date]     DATETIME       NULL
);

