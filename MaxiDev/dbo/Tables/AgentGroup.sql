CREATE TABLE [dbo].[AgentGroup] (
    [IdAgentGroup]   INT           IDENTITY (1, 1) NOT NULL,
    [Name]           VARCHAR (500) NOT NULL,
    [IdPrimaryAgent] INT           NOT NULL,
    CONSTRAINT [PK_AgentGroup] PRIMARY KEY CLUSTERED ([IdAgentGroup] ASC),
    CONSTRAINT [FK_AgentGroup_Agent] FOREIGN KEY ([IdPrimaryAgent]) REFERENCES [dbo].[Agent] ([IdAgent])
);

