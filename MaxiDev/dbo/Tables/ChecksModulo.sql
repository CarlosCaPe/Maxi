CREATE TABLE [dbo].[ChecksModulo] (
    [IdCheckModulo] INT            NOT NULL,
    [Description]   NVARCHAR (MAX) NOT NULL,
    [Visible]       BIT            NOT NULL,
    CONSTRAINT [PK_FeeChecksModulo] PRIMARY KEY CLUSTERED ([IdCheckModulo] ASC)
);

