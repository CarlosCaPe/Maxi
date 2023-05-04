CREATE TABLE [Corp].[AgentCollectTypeRelAgent] (
    [IdAgent]            INT      NOT NULL,
    [IdAgentCollectType] INT      NOT NULL,
    [IsDefault]          BIT      NOT NULL,
    [CreationDate]       DATETIME NOT NULL,
    [EnterByIdUser]      INT      NOT NULL,
    CONSTRAINT [PK_AgentCollectTypeRelAgent] PRIMARY KEY CLUSTERED ([IdAgent] ASC, [IdAgentCollectType] ASC),
    CONSTRAINT [FK_AgentCollectTypeRelAgent_EnterByIdUser] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [FK_AgentCollectTypeRelAgent_IdAgent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentCollectTypeRelAgent_IdAgentCollectType] FOREIGN KEY ([IdAgentCollectType]) REFERENCES [dbo].[AgentCollectType] ([IdAgentCollectType])
);

