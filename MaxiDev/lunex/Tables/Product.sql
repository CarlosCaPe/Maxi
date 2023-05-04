CREATE TABLE [lunex].[Product] (
    [SKU]             NVARCHAR (150) NOT NULL,
    [Product]         NVARCHAR (150) NOT NULL,
    [IdCarrier]       INT            NOT NULL,
    [IdCountry]       INT            NOT NULL,
    [IdGenericstatus] INT            NOT NULL,
    [EnteredByIdUser] INT            NOT NULL,
    [Margin]          MONEY          DEFAULT ((0)) NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161215-162037]
    ON [lunex].[Product]([SKU] ASC);

