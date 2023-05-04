CREATE TABLE [dbo].[AgentException] (
    [IdAgentException] INT           IDENTITY (1, 1) NOT NULL,
    [IdAgent]          INT           NOT NULL,
    [Exception]        BIT           NULL,
    [IdUser]           INT           NOT NULL,
    [Note]             VARCHAR (MAX) NOT NULL,
    [EnterDate]        DATETIME      NOT NULL,
    CONSTRAINT [PK_AgentException] PRIMARY KEY CLUSTERED ([IdAgentException] ASC),
    CONSTRAINT [FK_AgentException_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentException_Users] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IX_AgentException_IdAgent]
    ON [dbo].[AgentException]([IdAgent] ASC);

