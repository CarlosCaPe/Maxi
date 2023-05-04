CREATE TABLE [dbo].[AmountBaseByCurrency] (
    [CurrencyCode]  NCHAR (10) NOT NULL,
    [IdPaymentType] INT        NOT NULL,
    [AtmAmountBase] MONEY      NOT NULL,
    [NumberLength]  INT        NOT NULL,
    [MaxAmount]     MONEY      NOT NULL,
    CONSTRAINT [FK_AmountBaseByCurrency_PaymentType] FOREIGN KEY ([IdPaymentType]) REFERENCES [dbo].[PaymentType] ([IdPaymentType])
);

