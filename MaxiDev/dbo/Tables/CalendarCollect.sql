CREATE TABLE [dbo].[CalendarCollect] (
    [IdCalendarCollect]  INT      IDENTITY (1, 1) NOT NULL,
    [IdAgent]            INT      NOT NULL,
    [CreationDate]       DATETIME NOT NULL,
    [PayDate]            DATETIME NOT NULL,
    [EnterByIdUser]      INT      NOT NULL,
    [Amount]             MONEY    NOT NULL,
    [IdAgentCollectType] INT      NOT NULL,
    CONSTRAINT [PK_CalendarCollect] PRIMARY KEY CLUSTERED ([IdCalendarCollect] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_CalendarCollect_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_CalendarCollect_AgentCollectType] FOREIGN KEY ([IdAgentCollectType]) REFERENCES [dbo].[AgentCollectType] ([IdAgentCollectType]),
    CONSTRAINT [FK_CalendarCollect_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

