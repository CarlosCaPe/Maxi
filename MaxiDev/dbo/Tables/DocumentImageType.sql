CREATE TABLE [dbo].[DocumentImageType] (
    [IdDocumentImageType] INT            IDENTITY (1, 1) NOT NULL,
    [DocumentImageCode]   NVARCHAR (500) NOT NULL,
    CONSTRAINT [PK_DocumentImageType] PRIMARY KEY CLUSTERED ([IdDocumentImageType] ASC) WITH (FILLFACTOR = 90)
);

