CREATE TABLE [Operation].[ProductsSKUFeeBased] (
    [SKU] NVARCHAR (300) NOT NULL,
    [Fee] MONEY          DEFAULT ((0)) NOT NULL
);

