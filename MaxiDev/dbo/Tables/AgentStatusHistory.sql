CREATE TABLE [dbo].[AgentStatusHistory] (
    [IdAgentStatusHistory] INT            IDENTITY (1, 1) NOT NULL,
    [IdUser]               INT            NOT NULL,
    [IdAgent]              INT            NOT NULL,
    [IdAgentStatus]        INT            NOT NULL,
    [DateOfchange]         DATETIME       NOT NULL,
    [Note]                 NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_AgentStatusHistory] PRIMARY KEY CLUSTERED ([IdAgentStatusHistory] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentStatusHistory_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentStatusHistory_AgentStatus] FOREIGN KEY ([IdAgentStatus]) REFERENCES [dbo].[AgentStatus] ([IdAgentStatus]),
    CONSTRAINT [FK_AgentStatusHistory_Users] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IX_AgentStatusHistory_IdAgent_IdAgentStatus]
    ON [dbo].[AgentStatusHistory]([IdAgent] ASC, [IdAgentStatus] ASC)
    INCLUDE([IdAgentStatusHistory], [IdUser], [DateOfchange], [Note]);

