CREATE TABLE [dbo].[LengthRule] (
    [IdValidationRule] INT NOT NULL,
    [Minimum]          INT NOT NULL,
    [Maximo]           INT NOT NULL,
    CONSTRAINT [PK_LengthRule] PRIMARY KEY CLUSTERED ([IdValidationRule] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_LengthRule_ValidationRules] FOREIGN KEY ([IdValidationRule]) REFERENCES [dbo].[ValidationRules] ([IdValidationRule])
);

