CREATE TABLE [dbo].[GatewayCatalog] (
    [IdGatewayCatalog]     INT            IDENTITY (1, 1) NOT NULL,
    [IdGateway]            INT            NULL,
    [IdGatewayCatalogType] INT            NULL,
    [Code]                 NVARCHAR (200) NOT NULL,
    [IdReference]          INT            NOT NULL,
    [IdPaymentType]        INT            NOT NULL,
    CONSTRAINT [PK_GatewayCatalog] PRIMARY KEY CLUSTERED ([IdGatewayCatalog] ASC),
    CONSTRAINT [FK_GatewayCatalog_IdGateway] FOREIGN KEY ([IdGateway]) REFERENCES [dbo].[Gateway] ([IdGateway]),
    CONSTRAINT [FK_GatewayCatalog_IdGatewayCatalogType] FOREIGN KEY ([IdGatewayCatalogType]) REFERENCES [dbo].[GatewayCatalogType] ([IdGatewayCatalogType]),
    CONSTRAINT [FK_GatewayCatalog_PaymentType] FOREIGN KEY ([IdPaymentType]) REFERENCES [dbo].[PaymentType] ([IdPaymentType])
);

