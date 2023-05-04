CREATE TABLE [TransFerTo].[AgentSchema] (
    [IdSchema]         INT      NOT NULL,
    [IdAgent]          INT      NOT NULL,
    [DateOfLastchange] DATETIME NOT NULL,
    [EnterByIdUser]    INT      NOT NULL,
    CONSTRAINT [PK_TToAgentSchema] PRIMARY KEY CLUSTERED ([IdSchema] ASC, [IdAgent] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_TToAgentSchema_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_TToAgentSchema_TToSchema] FOREIGN KEY ([IdSchema]) REFERENCES [TransFerTo].[Schema] ([IdSchema])
);


GO
CREATE NONCLUSTERED INDEX [IX_AgentSchema_IdAgent]
    ON [TransFerTo].[AgentSchema]([IdAgent] ASC);

