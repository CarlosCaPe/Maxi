CREATE TABLE [MoneyOrder].[SaleRecordDetails] (
    [IdSaleRecordDetails] INT           IDENTITY (1, 1) NOT NULL,
    [IdSaleRecord]        INT           NOT NULL,
    [IdStatus]            INT           NOT NULL,
    [DateOfMovement]      DATETIME      NOT NULL,
    [Note]                VARCHAR (500) NULL,
    [EnterByIdUser]       INT           NOT NULL,
    CONSTRAINT [PF_SaleRecordDetails] PRIMARY KEY CLUSTERED ([IdSaleRecordDetails] ASC),
    CONSTRAINT [FK_SaleRecordDetails_SaleRecord] FOREIGN KEY ([IdSaleRecord]) REFERENCES [MoneyOrder].[SaleRecord] ([IdSaleRecord]),
    CONSTRAINT [FK_SaleRecordDetails_Status] FOREIGN KEY ([IdStatus]) REFERENCES [dbo].[Status] ([IdStatus]),
    CONSTRAINT [FK_SaleRecordDetails_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

