CREATE TABLE [dbo].[OFAC_ALT] (
    [ent_num]           BIGINT          NULL,
    [alt_num]           BIGINT          NULL,
    [alt_type]          NVARCHAR (100)  NULL,
    [alt_name]          NVARCHAR (2000) NULL,
    [alt_remarks]       NVARCHAR (2000) NULL,
    [ALT_PrincipalName] NVARCHAR (4000) NULL,
    [ALT_FirstLastName] NVARCHAR (4000) NULL,
    [OfacIndex]         INT             IDENTITY (1, 1) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [PK_OFAC_ALT]
    ON [dbo].[OFAC_ALT]([OfacIndex] ASC);


GO
CREATE NONCLUSTERED INDEX [OFAC_ALT_ENT_NUM]
    ON [dbo].[OFAC_ALT]([ent_num] ASC, [alt_name] ASC) WITH (FILLFACTOR = 100);

