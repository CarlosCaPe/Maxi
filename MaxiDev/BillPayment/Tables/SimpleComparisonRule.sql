CREATE TABLE [BillPayment].[SimpleComparisonRule] (
    [IdValidationRule] INT          NOT NULL,
    [ComparisonValue]  VARCHAR (50) NOT NULL,
    [Type]             VARCHAR (50) NOT NULL,
    [Expression]       VARCHAR (2)  NOT NULL,
    CONSTRAINT [PK_SimpleComparisonRule] PRIMARY KEY CLUSTERED ([IdValidationRule] ASC),
    CONSTRAINT [FK_SimpleComparisonRule_ValidationRules] FOREIGN KEY ([IdValidationRule]) REFERENCES [BillPayment].[ValidationRules] ([IdValidationRule])
);

