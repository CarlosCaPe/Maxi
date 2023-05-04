CREATE TABLE [dbo].[CheckEdits] (
    [IdCheckEdits] INT           IDENTITY (1, 1) NOT NULL,
    [IdCheck]      INT           NULL,
    [EditName]     VARCHAR (50)  NULL,
    [OriValue]     VARCHAR (100) NULL,
    [OriScore]     INT           NULL,
    [Value]        VARCHAR (100) NULL,
    [EditLevel]    SMALLINT      NULL,
    CONSTRAINT [PK_CheckEdits] PRIMARY KEY CLUSTERED ([IdCheckEdits] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_CheckEdits01]
    ON [dbo].[CheckEdits]([IdCheck] ASC, [EditName] ASC);

