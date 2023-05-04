CREATE TABLE [BillPayment].[RegularExpressionRule] (
    [IdValidationRule] INT           NOT NULL,
    [Pattern]          VARCHAR (500) NOT NULL,
    CONSTRAINT [PK_RegularExpressionRule] PRIMARY KEY CLUSTERED ([IdValidationRule] ASC),
    CONSTRAINT [FK_RegularExpressionRule_ValidationRules] FOREIGN KEY ([IdValidationRule]) REFERENCES [BillPayment].[ValidationRules] ([IdValidationRule])
);

