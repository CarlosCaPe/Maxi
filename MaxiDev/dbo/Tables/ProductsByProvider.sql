CREATE TABLE [dbo].[ProductsByProvider] (
    [IdProductsByProvider] INT           IDENTITY (1, 1) NOT NULL,
    [IdProvider]           INT           NULL,
    [IdGroup]              INT           NULL,
    [VendorName]           VARCHAR (MAX) NULL,
    [VendorID]             VARCHAR (MAX) NULL,
    [IdGenericStatus]      INT           NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161215-162732]
    ON [dbo].[ProductsByProvider]([IdProductsByProvider] ASC, [IdGenericStatus] ASC)
    INCLUDE([VendorName]);

