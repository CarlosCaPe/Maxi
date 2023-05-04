CREATE TABLE [dbo].[Groups] (
    [IdGroups]      INT           IDENTITY (1, 1) NOT NULL,
    [VendorSubType] VARCHAR (MAX) NULL,
    [Description]   VARCHAR (MAX) NULL
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161214-165156]
    ON [dbo].[Groups]([IdGroups] ASC)
    INCLUDE([VendorSubType]);

