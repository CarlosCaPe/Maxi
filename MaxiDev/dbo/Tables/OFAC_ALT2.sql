CREATE TABLE [dbo].[OFAC_ALT2] (
    [ent_num]           BIGINT          NULL,
    [alt_num]           BIGINT          NULL,
    [alt_type]          NVARCHAR (100)  NULL,
    [alt_name]          NVARCHAR (2000) NULL,
    [alt_remarks]       NVARCHAR (2000) NULL,
    [ALT_PrincipalName] NVARCHAR (4000) NULL,
    [ALT_FirstLastName] NVARCHAR (4000) NULL
);

