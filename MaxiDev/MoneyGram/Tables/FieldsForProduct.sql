CREATE TABLE [MoneyGram].[FieldsForProduct] (
    [IdFieldsForProduct] INT           IDENTITY (1, 1) NOT NULL,
    [XmlTag]             VARCHAR (100) NOT NULL,
    [FieldLabel]         VARCHAR (100) NULL,
    [DataType]           VARCHAR (100) NOT NULL,
    [CatalogResource]    VARCHAR (100) NULL,
    [DependsOn]          VARCHAR (100) NULL,
    [BaseFields]         VARCHAR (150) NULL,
    [Order]              INT           NOT NULL,
    [Active]             BIT           CONSTRAINT [DF_MoneyGramFieldsForProduct_Active] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_MoneyGramFieldsForProduct] PRIMARY KEY CLUSTERED ([IdFieldsForProduct] ASC)
);

