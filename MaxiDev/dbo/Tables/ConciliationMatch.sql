CREATE TABLE [dbo].[ConciliationMatch] (
    [IdConciliationMatch] INT      IDENTITY (1, 1) NOT NULL,
    [IdBankDeposit]       INT      NOT NULL,
    [IdAgentDeposit]      INT      NOT NULL,
    [CreationDate]        DATETIME NOT NULL,
    [IdUser]              INT      NOT NULL,
    CONSTRAINT [PK_ConciliationMatch] PRIMARY KEY CLUSTERED ([IdConciliationMatch] ASC),
    CONSTRAINT [FK_ConciliationMatch_AgentDeposit] FOREIGN KEY ([IdAgentDeposit]) REFERENCES [dbo].[AgentDeposit] ([IdAgentDeposit]),
    CONSTRAINT [FK_ConciliationMatch_BankDeposit] FOREIGN KEY ([IdBankDeposit]) REFERENCES [dbo].[BankDeposit] ([IdBankDeposit]),
    CONSTRAINT [FK_ConciliationMatch_User] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [UQ_ConciliationMatch_AgentDeposit] UNIQUE NONCLUSTERED ([IdAgentDeposit] ASC)
);

