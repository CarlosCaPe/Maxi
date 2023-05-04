CREATE TABLE [dbo].[AgentUser] (
    [IdAgent] INT NOT NULL,
    [IdUser]  INT NOT NULL,
    CONSTRAINT [PK_AgentUser_1] PRIMARY KEY CLUSTERED ([IdUser] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentUser_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentUser_Users] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IX_AgentUser_IdAgent]
    ON [dbo].[AgentUser]([IdAgent] ASC);

