CREATE TABLE [BillPayment].[LengthRule] (
    [IdValidationRule] INT NOT NULL,
    [Minimum]          INT NOT NULL,
    [Maximo]           INT NOT NULL,
    CONSTRAINT [PK_LengthRule] PRIMARY KEY CLUSTERED ([IdValidationRule] ASC),
    CONSTRAINT [FK_LengthRule_ValidationRules] FOREIGN KEY ([IdValidationRule]) REFERENCES [BillPayment].[ValidationRules] ([IdValidationRule])
);

