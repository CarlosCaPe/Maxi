CREATE TABLE [dbo].[RelationDocumentImageType] (
    [IdDocumentType]      INT NOT NULL,
    [IdDocumentImageType] INT NOT NULL,
    CONSTRAINT [PK_RelationDocumentImageType] PRIMARY KEY CLUSTERED ([IdDocumentType] ASC, [IdDocumentImageType] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_RelationDocumentImageType_DocumentImageType] FOREIGN KEY ([IdDocumentImageType]) REFERENCES [dbo].[DocumentImageType] ([IdDocumentImageType]),
    CONSTRAINT [FK_RelationDocumentImageType_DocumentType] FOREIGN KEY ([IdDocumentType]) REFERENCES [dbo].[DocumentTypes] ([IdDocumentType])
);

