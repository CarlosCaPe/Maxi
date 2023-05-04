CREATE TABLE [dbo].[AgentBankDepositAgentCollectTypeRelation] (
    [IdAgentBankDeposit] INT NOT NULL,
    [IdAgentCollectType] INT NOT NULL,
    PRIMARY KEY CLUSTERED ([IdAgentBankDeposit] ASC, [IdAgentCollectType] ASC),
    FOREIGN KEY ([IdAgentBankDeposit]) REFERENCES [dbo].[AgentBankDeposit] ([IdAgentBankDeposit]),
    FOREIGN KEY ([IdAgentCollectType]) REFERENCES [dbo].[AgentCollectType] ([IdAgentCollectType])
);

