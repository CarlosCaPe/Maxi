CREATE TABLE [dbo].[PayerCommission] (
    [IdPayerCommission]     INT      IDENTITY (1, 1) NOT NULL,
    [IdPayer]               INT      NOT NULL,
    [IdPaymentType]         INT      NOT NULL,
    [DateOfPayerCommission] DATETIME NOT NULL,
    [DateOfLastChange]      DATETIME NOT NULL,
    [EnterByIdUser]         INT      NOT NULL,
    [CommissionOld]         MONEY    NOT NULL,
    [CommissionNew]         MONEY    NOT NULL,
    [Active]                BIT      NOT NULL,
    CONSTRAINT [PK_PayerCommission] PRIMARY KEY CLUSTERED ([IdPayerCommission] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_PayerCommission_Payer] FOREIGN KEY ([IdPayer]) REFERENCES [dbo].[Payer] ([IdPayer]),
    CONSTRAINT [FK_PayerCommission_PaymentType] FOREIGN KEY ([IdPaymentType]) REFERENCES [dbo].[PaymentType] ([IdPaymentType]),
    CONSTRAINT [FK_PayerCommission_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

