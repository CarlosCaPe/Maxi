CREATE TABLE [dbo].[AgentPureMinutesInfo] (
    [IdAgent]                     INT NOT NULL,
    [IdFeeByOtherProducts]        INT NULL,
    [IdCommissionByOtherProducts] INT NOT NULL,
    CONSTRAINT [PK_AgentPureMinutesInfo] PRIMARY KEY CLUSTERED ([IdAgent] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentPureMinutesInfo_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentPureMinutesInfo_CommissionByProvider] FOREIGN KEY ([IdCommissionByOtherProducts]) REFERENCES [dbo].[CommissionByOtherProducts] ([IdCommissionByOtherProducts]),
    CONSTRAINT [FK_AgentPureMinutesInfo_FeeByProvider] FOREIGN KEY ([IdFeeByOtherProducts]) REFERENCES [dbo].[FeeByOtherProducts] ([IdFeeByOtherProducts])
);

