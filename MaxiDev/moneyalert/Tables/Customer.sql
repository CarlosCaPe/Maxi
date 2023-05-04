CREATE TABLE [moneyalert].[Customer] (
    [IdCustomer]       INT      NOT NULL,
    [IdCustomerMobile] INT      NOT NULL,
    [EnteredDate]      DATETIME NOT NULL,
    [DateOfLastChange] DATETIME NOT NULL,
    CONSTRAINT [PK_Customer_1] PRIMARY KEY CLUSTERED ([IdCustomer] ASC),
    CONSTRAINT [FK_Customer_CustomerMobile] FOREIGN KEY ([IdCustomerMobile]) REFERENCES [moneyalert].[CustomerMobile] ([IdCustomerMobile])
);

