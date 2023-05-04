CREATE TABLE [MoneyOrder].[SaleRecordOFACLog] (
    [IdSaleRecordOFACLog] INT     IDENTITY (1, 1) NOT NULL,
    [IdSaleRecord]        INT     NOT NULL,
    [CustomerScore]       TINYINT NOT NULL,
    [CustomerMatch]       XML     NULL,
    [RemitterScore]       TINYINT NOT NULL,
    [RemitterMatch]       XML     NULL,
    [MinMatchScore]       TINYINT NOT NULL,
    CONSTRAINT [PK_SaleRecordOFACLog] PRIMARY KEY CLUSTERED ([IdSaleRecordOFACLog] ASC),
    CONSTRAINT [FK_SaleRecordOFACLog_SaleRecord] FOREIGN KEY ([IdSaleRecord]) REFERENCES [MoneyOrder].[SaleRecord] ([IdSaleRecord])
);

