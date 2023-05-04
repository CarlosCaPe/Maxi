CREATE TABLE [dbo].[RegularExpressionRule] (
    [IdValidationRule] INT           NOT NULL,
    [Pattern]          VARCHAR (500) NOT NULL,
    CONSTRAINT [PK_RegularExpressionRule] PRIMARY KEY CLUSTERED ([IdValidationRule] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_RegularExpressionRule_ValidationRules] FOREIGN KEY ([IdValidationRule]) REFERENCES [dbo].[ValidationRules] ([IdValidationRule])
);

