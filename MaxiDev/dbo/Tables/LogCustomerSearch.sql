CREATE TABLE [dbo].[LogCustomerSearch] (
    [IdLogCustomer]      INT            IDENTITY (1, 1) NOT NULL,
    [IdCustomer]         INT            NOT NULL,
    [IdCustomerFidelity] INT            NOT NULL,
    [Request]            NVARCHAR (MAX) NULL,
    [Response]           NVARCHAR (MAX) NULL,
    [CreationDate]       DATETIME       NOT NULL,
    CONSTRAINT [PK_BillPayment.LogCustomerSearch] PRIMARY KEY CLUSTERED ([IdLogCustomer] ASC),
    CONSTRAINT [FK_LogCustomerSearch_Customer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer])
);

