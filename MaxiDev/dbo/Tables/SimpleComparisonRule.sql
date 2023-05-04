CREATE TABLE [dbo].[SimpleComparisonRule] (
    [IdValidationRule] INT          NOT NULL,
    [ComparisonValue]  VARCHAR (50) NOT NULL,
    [Type]             VARCHAR (50) NOT NULL,
    [Expression]       VARCHAR (2)  NOT NULL,
    CONSTRAINT [PK_SimpleComparisonRule] PRIMARY KEY CLUSTERED ([IdValidationRule] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_SimpleComparisonRule_ValidationRules] FOREIGN KEY ([IdValidationRule]) REFERENCES [dbo].[ValidationRules] ([IdValidationRule])
);

