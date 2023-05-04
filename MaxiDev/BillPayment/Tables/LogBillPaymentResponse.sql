CREATE TABLE [BillPayment].[LogBillPaymentResponse] (
    [IdLogBillPayment]  INT            IDENTITY (1, 1) NOT NULL,
    [IdAgent]           INT            NOT NULL,
    [IdUser]            INT            NOT NULL,
    [IdAggregator]      INT            NOT NULL,
    [Request]           NVARCHAR (MAX) NULL,
    [Response]          NVARCHAR (MAX) NULL,
    [DateLastChange]    DATETIME       NOT NULL,
    [TypeMovent]        NVARCHAR (255) DEFAULT ('') NOT NULL,
    [IdProductTransfer] BIGINT         DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_LogBillPayment] PRIMARY KEY CLUSTERED ([IdLogBillPayment] ASC),
    CONSTRAINT [FK_LogBillPaymentResponse_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_LogBillPaymentResponse_Aggregator] FOREIGN KEY ([IdAggregator]) REFERENCES [BillPayment].[Aggregator] ([IdAggregator]),
    CONSTRAINT [FK_LogBillPaymentResponse_User] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

