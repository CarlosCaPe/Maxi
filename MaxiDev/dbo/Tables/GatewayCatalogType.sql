CREATE TABLE [dbo].[GatewayCatalogType] (
    [IdGatewayCatalogType] INT            IDENTITY (1, 1) NOT NULL,
    [Name]                 NVARCHAR (100) NOT NULL,
    [Schema]               NVARCHAR (100) NOT NULL,
    [Table]                NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_GatewayCatalogType] PRIMARY KEY CLUSTERED ([IdGatewayCatalogType] ASC),
    UNIQUE NONCLUSTERED ([Name] ASC)
);

