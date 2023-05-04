CREATE TABLE [lunex].[SKUTypeToOtherProduct] (
    [IdSKUTypeToOtherProduct] INT             IDENTITY (1, 1) NOT NULL,
    [SKUType]                 NVARCHAR (1000) NOT NULL,
    [IdOtherProduct]          INT             NOT NULL,
    CONSTRAINT [PK_SKUTypeToOtherProduct] PRIMARY KEY CLUSTERED ([IdSKUTypeToOtherProduct] ASC),
    CONSTRAINT [FK_SKUTypeToOtherProduct_IdOtherProduct] FOREIGN KEY ([IdOtherProduct]) REFERENCES [dbo].[OtherProducts] ([IdOtherProducts])
);

