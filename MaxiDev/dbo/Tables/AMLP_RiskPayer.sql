CREATE TABLE [dbo].[AMLP_RiskPayer] (
    [IdRiskPayer]   INT IDENTITY (1, 1) NOT NULL,
    [IdPayer]       INT NOT NULL,
    [IdPaymentType] INT NOT NULL,
    [RiskValue]     INT NOT NULL,
    CONSTRAINT [PK_AMLPRiskPayer] PRIMARY KEY CLUSTERED ([IdRiskPayer] ASC),
    CONSTRAINT [FK_AMLPRiskPayer_IdPayer] FOREIGN KEY ([IdPayer]) REFERENCES [dbo].[Payer] ([IdPayer]),
    CONSTRAINT [FK_AMLPRiskPayer_IdPaymentType] FOREIGN KEY ([IdPaymentType]) REFERENCES [dbo].[PaymentType] ([IdPaymentType]),
    CONSTRAINT [UQ_AMLPRiskPayer] UNIQUE NONCLUSTERED ([IdPayer] ASC, [IdPaymentType] ASC)
);

