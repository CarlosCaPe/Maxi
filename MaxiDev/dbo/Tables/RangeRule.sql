CREATE TABLE [dbo].[RangeRule] (
    [IdValidationRule] INT          NOT NULL,
    [FromValue]        VARCHAR (50) NOT NULL,
    [ToValue]          VARCHAR (50) NOT NULL,
    [Type]             VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_RangeRule] PRIMARY KEY CLUSTERED ([IdValidationRule] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_RangeRule_ValidationRules] FOREIGN KEY ([IdValidationRule]) REFERENCES [dbo].[ValidationRules] ([IdValidationRule])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo en el que se va comparar. Debe ser una implementacion de ICompare', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RangeRule', @level2type = N'COLUMN', @level2name = N'Type';

