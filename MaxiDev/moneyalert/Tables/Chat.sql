CREATE TABLE [moneyalert].[Chat] (
    [IdChat]              INT      IDENTITY (1, 1) NOT NULL,
    [IdBeneficiaryMobile] INT      NOT NULL,
    [IdCustomerMobile]    INT      NOT NULL,
    [EnteredDate]         DATETIME NOT NULL,
    [DateOfLastChange]    DATETIME NOT NULL,
    CONSTRAINT [PK_Chat] PRIMARY KEY CLUSTERED ([IdChat] ASC),
    CONSTRAINT [FK_Chat_BeneficiaryMobile] FOREIGN KEY ([IdBeneficiaryMobile]) REFERENCES [moneyalert].[BeneficiaryMobile] ([IdBeneficiaryMobile]),
    CONSTRAINT [FK_Chat_CustomerMobile] FOREIGN KEY ([IdCustomerMobile]) REFERENCES [moneyalert].[CustomerMobile] ([IdCustomerMobile])
);

