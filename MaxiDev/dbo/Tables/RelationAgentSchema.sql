CREATE TABLE [dbo].[RelationAgentSchema] (
    [IdAgentSchema]    INT      NOT NULL,
    [IdAgent]          INT      NOT NULL,
    [DateOfLastchange] DATETIME NOT NULL,
    [EnterByIdUser]    INT      NOT NULL,
    [Spread]           MONEY    NOT NULL,
    [EndDateSpread]    DATETIME NULL,
    CONSTRAINT [PK_RelationAgentSchema] PRIMARY KEY CLUSTERED ([IdAgentSchema] ASC, [IdAgent] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_RelationAgentSchema_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_RelationAgentSchema_AgentSchema] FOREIGN KEY ([IdAgentSchema]) REFERENCES [dbo].[AgentSchema] ([IdAgentSchema])
);

