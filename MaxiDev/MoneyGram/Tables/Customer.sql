CREATE TABLE [MoneyGram].[Customer] (
    [IdCustomerRelation]  BIGINT       NOT NULL,
    [IdCustomer]          INT          NOT NULL,
    [IdCustomerMoneyGram] VARCHAR (20) NOT NULL,
    [CreationDate]        DATETIME     NOT NULL,
    [EnterByIdUser]       INT          NOT NULL,
    CONSTRAINT [PK_MoneyGramCustomer] PRIMARY KEY CLUSTERED ([IdCustomerRelation] ASC),
    CONSTRAINT [FK_MoneyGramCustomer_Customer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [UQ_MoneyGramCustomer_IdCustomer] UNIQUE NONCLUSTERED ([IdCustomer] ASC),
    CONSTRAINT [UQ_MoneyGramCustomer_IdCustomerMoneyGram] UNIQUE NONCLUSTERED ([IdCustomerMoneyGram] ASC)
);

