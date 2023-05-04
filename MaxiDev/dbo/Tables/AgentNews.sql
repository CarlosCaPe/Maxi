CREATE TABLE [dbo].[AgentNews] (
    [IdNews]       INT      NOT NULL,
    [IdAgent]      INT      NOT NULL,
    [DateOfRead]   DATETIME NOT NULL,
    [ReadByIdUser] INT      NOT NULL,
    [IsRead]       BIT      DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AgentNews] PRIMARY KEY CLUSTERED ([IdNews] ASC, [IdAgent] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentNews_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentNews_News] FOREIGN KEY ([IdNews]) REFERENCES [dbo].[News] ([IdNews]),
    CONSTRAINT [FK_AgentNews_Users] FOREIGN KEY ([ReadByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

