CREATE TABLE [dbo].[NSCatalogEntity] (
    [IdCatalogEntity] INT            IDENTITY (1, 1) NOT NULL,
    [IdNSEntity]      INT            NULL,
    [InternalId]      INT            NOT NULL,
    [Name]            NVARCHAR (200) NOT NULL,
    [ExternalId]      NVARCHAR (200) NULL,
    [CreationDate]    DATETIME       CONSTRAINT [DF_NSCatalogEntity_CreationDate] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_NSCatalogEntity] PRIMARY KEY CLUSTERED ([IdCatalogEntity] ASC),
    CONSTRAINT [FK_NSCatalogEntity_NSEntity] FOREIGN KEY ([IdNSEntity]) REFERENCES [dbo].[NSEntity] ([Id]),
    CONSTRAINT [UQ_NSCatalogEntity] UNIQUE NONCLUSTERED ([IdNSEntity] ASC, [InternalId] ASC)
);

