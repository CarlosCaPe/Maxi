CREATE TABLE [dbo].[BillPaymentNotes] (
    [IdBillPaymentNote]         INT            IDENTITY (1, 1) NOT NULL,
    [IdBillPayment]             INT            NOT NULL,
    [IdUser]                    INT            NOT NULL,
    [Note]                      NVARCHAR (250) NULL,
    [LastChange_LastUserChange] NVARCHAR (MAX) NULL,
    [LastChange_LastDateChange] DATETIME       NOT NULL,
    [LastChange_LastIpChange]   NVARCHAR (MAX) NULL,
    [LastChange_LastNoteChange] NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([IdBillPaymentNote] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [BillPayment_Notes] FOREIGN KEY ([IdBillPayment]) REFERENCES [dbo].[BillPaymentTransactions] ([IdBillPayment]),
    CONSTRAINT [User_BP_Notes] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

