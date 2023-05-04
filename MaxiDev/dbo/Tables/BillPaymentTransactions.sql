CREATE TABLE [dbo].[BillPaymentTransactions] (
    [IdBillPayment]                 INT             IDENTITY (1, 1) NOT NULL,
    [IdUser]                        INT             NOT NULL,
    [IdAgent]                       INT             NOT NULL,
    [BillerPaymentProviderVendorId] NVARCHAR (MAX)  NULL,
    [MerchId]                       NVARCHAR (MAX)  NULL,
    [TrackingNumber]                NVARCHAR (MAX)  NULL,
    [ReferenceNumber]               NVARCHAR (MAX)  NULL,
    [BatchNumber]                   NVARCHAR (MAX)  NULL,
    [BillPaymentProviderResponse]   NVARCHAR (MAX)  NULL,
    [AccountNumber]                 NVARCHAR (MAX)  NULL,
    [PaymentDate]                   DATETIME        NOT NULL,
    [ReceiptAmount]                 DECIMAL (18, 2) NOT NULL,
    [Status]                        INT             NOT NULL,
    [AltAccountNumber]              NVARCHAR (MAX)  NULL,
    [CustomField1]                  NVARCHAR (MAX)  NULL,
    [CustomField2]                  NVARCHAR (MAX)  NULL,
    [LastReturnMessage]             NVARCHAR (MAX)  NULL,
    [LastReturnCode]                NVARCHAR (MAX)  NULL,
    [IdBiller]                      INT             NOT NULL,
    [CustomerLastName]              NVARCHAR (MAX)  NULL,
    [CustomerMiddleName]            NVARCHAR (MAX)  NULL,
    [CustomerFirstName]             NVARCHAR (MAX)  NULL,
    [CustomerOccupation]            NVARCHAR (MAX)  NULL,
    [CustomerAddress]               NVARCHAR (MAX)  NULL,
    [CustomerCity]                  NVARCHAR (MAX)  NULL,
    [CustomerState]                 NVARCHAR (MAX)  NULL,
    [CustomerZip]                   NVARCHAR (MAX)  NULL,
    [CustomerTelephone]             NVARCHAR (MAX)  NULL,
    [CustomerIdType]                INT             NOT NULL,
    [CustomerIdIssuer]              NVARCHAR (MAX)  NULL,
    [CustomerIdNumber]              NVARCHAR (MAX)  NULL,
    [CustomerSsn]                   NVARCHAR (MAX)  NULL,
    [OnBehalf]                      BIT             NOT NULL,
    [BehalfLastName]                NVARCHAR (MAX)  NULL,
    [BehalfMiddleName]              NVARCHAR (MAX)  NULL,
    [BehalfFirstName]               NVARCHAR (MAX)  NULL,
    [BehalfOccupation]              NVARCHAR (MAX)  NULL,
    [BehalfAddress]                 NVARCHAR (MAX)  NULL,
    [BehalfCity]                    NVARCHAR (MAX)  NULL,
    [BehalfState]                   NVARCHAR (MAX)  NULL,
    [BehalfZip]                     NVARCHAR (MAX)  NULL,
    [BehalfTelephone]               NVARCHAR (MAX)  NULL,
    [BehalfIdType]                  INT             NOT NULL,
    [BehalfIdIssuer]                NVARCHAR (MAX)  NULL,
    [BehalfIdNumber]                NVARCHAR (MAX)  NULL,
    [BehalfSsn]                     NVARCHAR (MAX)  NULL,
    [CustomerDob]                   DATETIME        NOT NULL,
    [BehalfDob]                     DATETIME        NOT NULL,
    [Fee]                           MONEY           NOT NULL,
    [BillPaymentProviderFee]        DECIMAL (18, 2) NOT NULL,
    [AgentCommission]               DECIMAL (18, 2) NOT NULL,
    [CorpCommission]                DECIMAL (18, 2) NOT NULL,
    [LastChange_LastUserChange]     NVARCHAR (MAX)  NULL,
    [LastChange_LastDateChange]     DATETIME        NOT NULL,
    [LastChange_LastIpChange]       NVARCHAR (MAX)  NULL,
    [LastChange_LastNoteChange]     NVARCHAR (MAX)  NULL,
    [PostingMessage]                NVARCHAR (MAX)  NULL,
    [ReturnMessage]                 NVARCHAR (MAX)  NULL,
    [ReceiptMessage]                NVARCHAR (MAX)  NULL,
    [CancelUser]                    INT             NULL,
    [CancelDate]                    DATETIME        NULL,
    [BillAccountId]                 INT             NULL,
    [CustomerId]                    INT             NULL,
    [IdCarrier]                     INT             NULL,
    [UpdatedFee]                    BIT             NOT NULL,
    [CellularNumber]                VARCHAR (100)   NULL,
    PRIMARY KEY CLUSTERED ([IdBillPayment] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [BillAccount_Payments] FOREIGN KEY ([BillAccountId]) REFERENCES [dbo].[BillAccounts] ([IdBillAccounts]),
    CONSTRAINT [Customer_BillPayments] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer])
);


GO
CREATE NONCLUSTERED INDEX [IDX_BillPaymentTransactionsCustomerIdReceiptAmountPaymentDateStatus]
    ON [dbo].[BillPaymentTransactions]([CustomerId] ASC)
    INCLUDE([ReceiptAmount], [PaymentDate], [Status]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX1_BillPaymentTransactions]
    ON [dbo].[BillPaymentTransactions]([IdAgent] ASC, [PaymentDate] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_BillPaymentTransactions_PaymentDate_Status]
    ON [dbo].[BillPaymentTransactions]([PaymentDate] ASC, [Status] ASC)
    INCLUDE([IdBillPayment], [IdAgent]);

