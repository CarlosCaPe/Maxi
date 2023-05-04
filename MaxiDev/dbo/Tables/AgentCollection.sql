CREATE TABLE [dbo].[AgentCollection] (
    [IdAgentCollection] INT      IDENTITY (1, 1) NOT NULL,
    [IdAgent]           INT      NOT NULL,
    [AmountToPay]       MONEY    NOT NULL,
    [Fee]               MONEY    DEFAULT ((0)) NOT NULL,
    [EnterByIdUser]     INT      NOT NULL,
    [CreationDate]      DATETIME NOT NULL,
    [DateofLastChange]  DATETIME NOT NULL,
    CONSTRAINT [PK_AgentCollection] PRIMARY KEY CLUSTERED ([IdAgentCollection] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentCollection_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentCollection_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

