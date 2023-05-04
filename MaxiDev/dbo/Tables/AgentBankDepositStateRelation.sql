CREATE TABLE [dbo].[AgentBankDepositStateRelation] (
    [IdAgentBankDeposit] INT NOT NULL,
    [IdState]            INT NOT NULL,
    PRIMARY KEY CLUSTERED ([IdAgentBankDeposit] ASC, [IdState] ASC),
    FOREIGN KEY ([IdAgentBankDeposit]) REFERENCES [dbo].[AgentBankDeposit] ([IdAgentBankDeposit]),
    FOREIGN KEY ([IdState]) REFERENCES [dbo].[State] ([IdState])
);

