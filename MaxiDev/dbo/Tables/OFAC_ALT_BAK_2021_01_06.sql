﻿CREATE TABLE [dbo].[OFAC_ALT_BAK_2021_01_06] (
    [ent_num]           BIGINT          NULL,
    [alt_num]           BIGINT          NULL,
    [alt_type]          NVARCHAR (100)  NULL,
    [alt_name]          NVARCHAR (2000) NULL,
    [alt_remarks]       NVARCHAR (2000) NULL,
    [ALT_PrincipalName] NVARCHAR (4000) NULL,
    [ALT_FirstLastName] NVARCHAR (4000) NULL,
    [OfacIndex]         INT             IDENTITY (1, 1) NOT NULL
);

