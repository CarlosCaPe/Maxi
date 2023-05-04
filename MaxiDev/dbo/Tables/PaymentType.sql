CREATE TABLE [dbo].[PaymentType] (
    [IdPaymentType] INT            NOT NULL,
    [PaymentName]   NVARCHAR (MAX) NOT NULL,
    [LastChange]    DATETIME       NOT NULL,
    [IdUser]        INT            NOT NULL,
    CONSTRAINT [PK_PaymentType] PRIMARY KEY CLUSTERED ([IdPaymentType] ASC) WITH (FILLFACTOR = 90)
);

