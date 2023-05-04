CREATE TABLE [BillPayment].[RangeRule] (
    [IdValidationRule] INT          NOT NULL,
    [FromValue]        VARCHAR (50) NOT NULL,
    [ToValue]          VARCHAR (50) NOT NULL,
    [Type]             VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_RangeRule] PRIMARY KEY CLUSTERED ([IdValidationRule] ASC),
    CONSTRAINT [FK_RangeRule_ValidationRules] FOREIGN KEY ([IdValidationRule]) REFERENCES [BillPayment].[ValidationRules] ([IdValidationRule])
);

