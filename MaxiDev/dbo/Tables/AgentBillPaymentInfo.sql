CREATE TABLE [dbo].[AgentBillPaymentInfo] (
    [IdAgent]                     INT   NOT NULL,
    [AmountForClassF]             MONEY NOT NULL,
    [IdFeeByOtherProducts]        INT   NOT NULL,
    [IdCommissionByOtherProducts] INT   NOT NULL,
    CONSTRAINT [PK_AgentBillPaymentInfo] PRIMARY KEY CLUSTERED ([IdAgent] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentBillPaymentInfo_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentBillPaymentInfo_CommissionByProvider] FOREIGN KEY ([IdCommissionByOtherProducts]) REFERENCES [dbo].[CommissionByOtherProducts] ([IdCommissionByOtherProducts]),
    CONSTRAINT [FK_AgentBillPaymentInfo_FeeByProvider] FOREIGN KEY ([IdFeeByOtherProducts]) REFERENCES [dbo].[FeeByOtherProducts] ([IdFeeByOtherProducts])
);

