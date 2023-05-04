CREATE TABLE [dbo].[AgentPc] (
    [IdPcIdentifier] INT NOT NULL,
    [IdAgent]        INT NOT NULL,
    CONSTRAINT [PK_AgentPc] PRIMARY KEY CLUSTERED ([IdPcIdentifier] ASC, [IdAgent] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentPc_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentPc_PcIdentifier] FOREIGN KEY ([IdPcIdentifier]) REFERENCES [dbo].[PcIdentifier] ([IdPcIdentifier])
);


GO
CREATE NONCLUSTERED INDEX [IX_AgentPc_IdAgent]
    ON [dbo].[AgentPc]([IdAgent] ASC);

