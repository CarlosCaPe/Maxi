CREATE TABLE [dbo].[AgentBalanceDetail] (
    [IdAgentBalance] INT   NOT NULL,
    [TotalAmount]    MONEY NOT NULL,
    [CGS]            MONEY NOT NULL,
    [Fee]            MONEY NOT NULL,
    [ProviderFee]    MONEY NOT NULL,
    [CorpCommission] MONEY NOT NULL,
    PRIMARY KEY CLUSTERED ([IdAgentBalance] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [AgentBalanceDetial_AgentBalance] FOREIGN KEY ([IdAgentBalance]) REFERENCES [dbo].[AgentBalance] ([IdAgentBalance])
);

