CREATE TABLE [dbo].[MaskConfiguration] (
    [IdMaskConfiguration] INT            IDENTITY (1, 1) NOT NULL,
    [Name]                NVARCHAR (100) NULL,
    [MaskFormat]          NVARCHAR (200) NOT NULL,
    [FolioLength]         INT            NULL,
    PRIMARY KEY CLUSTERED ([IdMaskConfiguration] ASC),
    UNIQUE NONCLUSTERED ([Name] ASC)
);

