CREATE TABLE [dbo].[AgentPureMinutesTopUpInfo] (
    [IdAgent]                     INT NOT NULL,
    [IdFeeByOtherProducts]        INT NULL,
    [IdCommissionByOtherProducts] INT NOT NULL,
    CONSTRAINT [PK_AgentPureMinutesTopUpInfo] PRIMARY KEY CLUSTERED ([IdAgent] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentPureMinutesTopUpInfo_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentPureMinutesTopUpInfo_CommissionByProvider] FOREIGN KEY ([IdCommissionByOtherProducts]) REFERENCES [dbo].[CommissionByOtherProducts] ([IdCommissionByOtherProducts]),
    CONSTRAINT [FK_AgentPureMinutesTopUpInfo_FeeByProvider] FOREIGN KEY ([IdFeeByOtherProducts]) REFERENCES [dbo].[FeeByOtherProducts] ([IdFeeByOtherProducts])
);

