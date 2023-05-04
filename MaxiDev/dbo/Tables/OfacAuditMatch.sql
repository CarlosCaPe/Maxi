CREATE TABLE [dbo].[OfacAuditMatch] (
    [IdOfacAuditMatch]  INT             IDENTITY (1, 1) NOT NULL,
    [IdOfacAuditDetail] INT             NOT NULL,
    [sdn_name]          NVARCHAR (4000) NULL,
    [sdn_remarks]       NVARCHAR (4000) NULL,
    [alt_type]          NVARCHAR (400)  NULL,
    [alt_name]          NVARCHAR (2000) NULL,
    [alt_remarks]       NVARCHAR (2000) NULL,
    [add_address]       NVARCHAR (400)  NULL,
    [add_city_name]     NVARCHAR (400)  NULL,
    [add_country]       NVARCHAR (400)  NULL,
    [add_remarks]       NVARCHAR (400)  NULL,
    CONSTRAINT [PK_OfacAuditMatch] PRIMARY KEY CLUSTERED ([IdOfacAuditMatch] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_OfacAuditMatch_OfactAuditDetail] FOREIGN KEY ([IdOfacAuditDetail]) REFERENCES [dbo].[OfacAuditDetail] ([IdOfacAuditDetail])
);


GO
CREATE NONCLUSTERED INDEX [IX_OfacAuditMatch_IdOfacAuditDetail]
    ON [dbo].[OfacAuditMatch]([IdOfacAuditDetail] ASC)
    INCLUDE([IdOfacAuditMatch], [sdn_name], [sdn_remarks], [alt_type], [alt_name], [alt_remarks], [add_address], [add_city_name], [add_country], [add_remarks]);

