CREATE TABLE [dbo].[BillPaymentDetails] (
    [IdBillPaymentDetail] INT            IDENTITY (1, 1) NOT NULL,
    [Code]                NVARCHAR (MAX) NULL,
    [Description]         NVARCHAR (MAX) NULL,
    [IdBillPayment]       INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([IdBillPaymentDetail] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [BillPayment_BillPaymentDetails] FOREIGN KEY ([IdBillPayment]) REFERENCES [dbo].[BillPaymentTransactions] ([IdBillPayment])
);


GO
CREATE NONCLUSTERED INDEX [IX_BillPaymentDetails_IdBillPayment]
    ON [dbo].[BillPaymentDetails]([IdBillPayment] ASC)
    INCLUDE([IdBillPaymentDetail]);

