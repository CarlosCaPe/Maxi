﻿CREATE TABLE [dbo].[OFAC_SDN] (
    [ent_num]           BIGINT          NOT NULL,
    [SDN_name]          NVARCHAR (4000) NULL,
    [SDN_type]          NVARCHAR (200)  NULL,
    [program]           NVARCHAR (200)  NULL,
    [title]             NVARCHAR (200)  NULL,
    [call_sign]         NVARCHAR (200)  NULL,
    [vess_type]         NVARCHAR (200)  NULL,
    [tonnage]           NVARCHAR (200)  NULL,
    [GRT]               NVARCHAR (200)  NULL,
    [vess_flag]         NVARCHAR (200)  NULL,
    [vess_owner]        NVARCHAR (400)  NULL,
    [remarks]           NVARCHAR (4000) NULL,
    [SDN_PrincipalName] NVARCHAR (4000) NULL,
    [SDN_FirstLastName] NVARCHAR (4000) NULL,
    [OfacIndex]         INT             IDENTITY (1, 1) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [PK_OFAC_SDN]
    ON [dbo].[OFAC_SDN]([OfacIndex] ASC);


GO
CREATE NONCLUSTERED INDEX [OFAC_SDN_ENT_NUM]
    ON [dbo].[OFAC_SDN]([ent_num] ASC, [SDN_name] ASC, [SDN_type] ASC) WITH (FILLFACTOR = 100);

