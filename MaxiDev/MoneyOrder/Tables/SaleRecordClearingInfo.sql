CREATE TABLE [MoneyOrder].[SaleRecordClearingInfo] (
    [IdSaleRecordClearingInfo] INT      IDENTITY (1, 1) NOT NULL,
    [IdSaleRecord]             INT      NOT NULL,
    [DateOfMovement]           DATETIME NOT NULL,
    [ClearingDate]             DATETIME NOT NULL,
    [ClearingAmount]           MONEY    NULL,
    [EnterByIdUser]            INT      NOT NULL,
    CONSTRAINT [PF_SaleRecordClearingInfo] PRIMARY KEY CLUSTERED ([IdSaleRecordClearingInfo] ASC),
    CONSTRAINT [FK_SaleRecordClearingInfo_SaleRecord] FOREIGN KEY ([IdSaleRecord]) REFERENCES [MoneyOrder].[SaleRecord] ([IdSaleRecord]),
    CONSTRAINT [FK_SaleRecordClearingInfo_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

