CREATE TABLE [MoneyOrder].[SaleRecordBrokenRules] (
    [IdSaleRecordBrokenRules] INT           IDENTITY (1, 1) NOT NULL,
    [IdSaleRecord]            INT           NOT NULL,
    [IdRule]                  INT           NOT NULL,
    [MessageInSpanish]        VARCHAR (500) NULL,
    [MessageInEnglish]        VARCHAR (500) NULL,
    CONSTRAINT [PK_SaleRecordBrokenRules] PRIMARY KEY CLUSTERED ([IdSaleRecordBrokenRules] ASC),
    CONSTRAINT [FK_SaleRecordBrokenRules_KYCRule] FOREIGN KEY ([IdRule]) REFERENCES [dbo].[KYCRule] ([IdRule]),
    CONSTRAINT [FK_SaleRecordBrokenRules_SaleRecord] FOREIGN KEY ([IdSaleRecord]) REFERENCES [MoneyOrder].[SaleRecord] ([IdSaleRecord])
);

