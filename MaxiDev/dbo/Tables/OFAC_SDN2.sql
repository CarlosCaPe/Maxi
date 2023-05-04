CREATE TABLE [dbo].[OFAC_SDN2] (
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
    [SDN_FirstLastName] NVARCHAR (4000) NULL
);

