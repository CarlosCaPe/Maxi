CREATE TABLE [dbo].[BancoIndustrialGeneradorIdFiles] (
    [IdFile]          INT      NULL,
    [DateOfGenerator] DATETIME NULL
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161213-100554]
    ON [dbo].[BancoIndustrialGeneradorIdFiles]([DateOfGenerator] ASC);

