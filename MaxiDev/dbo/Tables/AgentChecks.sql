CREATE TABLE [dbo].[AgentChecks] (
    [IdAgent]        INT NOT NULL,
    [IdChecksModulo] INT NOT NULL,
    CONSTRAINT [PK_AgentChecks] PRIMARY KEY CLUSTERED ([IdAgent] ASC, [IdChecksModulo] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentChecksByProvider_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent])
);

