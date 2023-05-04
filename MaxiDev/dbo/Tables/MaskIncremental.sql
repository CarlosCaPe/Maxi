CREATE TABLE [dbo].[MaskIncremental] (
    [IdMaskIncremental]   INT            IDENTITY (1, 1) NOT NULL,
    [IdMaskConfiguration] INT            NULL,
    [MaskFormat]          NVARCHAR (200) NOT NULL,
    [LastFolio]           INT            NOT NULL,
    FOREIGN KEY ([IdMaskConfiguration]) REFERENCES [dbo].[MaskConfiguration] ([IdMaskConfiguration])
);

