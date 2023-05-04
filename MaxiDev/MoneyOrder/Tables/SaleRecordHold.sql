CREATE TABLE [MoneyOrder].[SaleRecordHold] (
    [IdSaleRecordHold] INT      IDENTITY (1, 1) NOT NULL,
    [IdSaleRecord]     INT      NOT NULL,
    [IdStatus]         INT      NOT NULL,
    [IsReleased]       BIT      NULL,
    [DateOfValidation] DATETIME NOT NULL,
    [DateOfLastChange] DATETIME NOT NULL,
    [EnterByIdUser]    INT      NOT NULL,
    CONSTRAINT [PK_SaleRecordHold] PRIMARY KEY CLUSTERED ([IdSaleRecordHold] ASC),
    CONSTRAINT [FK_SaleRecordHold_SaleRecord] FOREIGN KEY ([IdSaleRecord]) REFERENCES [MoneyOrder].[SaleRecord] ([IdSaleRecord]),
    CONSTRAINT [FK_SaleRecordHold_Status] FOREIGN KEY ([IdStatus]) REFERENCES [dbo].[Status] ([IdStatus]),
    CONSTRAINT [FK_SaleRecordHold_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

