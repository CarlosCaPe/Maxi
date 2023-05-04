CREATE TABLE [dbo].[AgentCurrentBalance] (
    [IdAgentCurrentBalance] INT   IDENTITY (1, 1) NOT NULL,
    [IdAgent]               INT   NOT NULL,
    [Balance]               MONEY NOT NULL,
    CONSTRAINT [PK_AgentCurrentBalance] PRIMARY KEY CLUSTERED ([IdAgentCurrentBalance] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentCurrentBalance_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_AgentCurrentBalance]
    ON [dbo].[AgentCurrentBalance]([IdAgent] ASC) WITH (FILLFACTOR = 90);

