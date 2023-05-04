CREATE TABLE [dbo].[CardVIP] (
    [IdCardVIP]       INT          IDENTITY (1, 1) NOT NULL,
    [IdCustomer]      INT          NOT NULL,
    [CardNumber]      VARCHAR (20) NOT NULL,
    [IdGenericStatus] INT          NOT NULL,
    CONSTRAINT [PK_CardVIP] PRIMARY KEY CLUSTERED ([IdCardVIP] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_CardVIP_Customer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_CardVIP_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus])
);


GO
CREATE NONCLUSTERED INDEX [idxCardNumberIdGeneric]
    ON [dbo].[CardVIP]([CardNumber] ASC, [IdGenericStatus] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IDX_CardVIP_IdCustomerIdGenericStatus]
    ON [dbo].[CardVIP]([IdCustomer] ASC, [IdGenericStatus] ASC);


GO
CREATE NONCLUSTERED INDEX [CardVipIdCustomerIdGenericStatusIncludeCardNumber]
    ON [dbo].[CardVIP]([IdGenericStatus] ASC)
    INCLUDE([IdCustomer], [CardNumber]);

