CREATE TABLE [dbo].[MaxiCollection] (
    [IdMaxiCollection]    INT      IDENTITY (1, 1) NOT NULL,
    [IdAgent]             INT      NULL,
    [Amount]              MONEY    NULL,
    [CollectAmount]       MONEY    NULL,
    [IdAgentCollectType]  INT      NULL,
    [DateOfCollection]    DATETIME NULL,
    [IdAgentClass]        INT      NULL,
    [IdAgentStatus]       INT      NULL,
    [AmountByCalendar]    MONEY    NULL,
    [AmountByLastDay]     MONEY    NULL,
    [AmountByCollectPlan] MONEY    NULL,
    [DateOfDebit]         DATETIME NULL,
    CONSTRAINT [PK_IdMaxiCollection] PRIMARY KEY CLUSTERED ([IdMaxiCollection] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_MaxiCollection_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent])
);


GO
CREATE NONCLUSTERED INDEX [IX_MaxiCollection_IdAgent_DateOfCollection_AmountByCalendar]
    ON [dbo].[MaxiCollection]([IdAgent] ASC, [DateOfCollection] ASC, [AmountByCalendar] ASC)
    INCLUDE([AmountByCollectPlan], [AmountByLastDay], [Amount], [CollectAmount]);


GO
CREATE NONCLUSTERED INDEX [IX_MaxiCollection_DateOfCollection]
    ON [dbo].[MaxiCollection]([DateOfCollection] ASC)
    INCLUDE([IdAgent], [IdAgentCollectType], [AmountByCalendar], [AmountByLastDay], [AmountByCollectPlan], [Amount], [CollectAmount], [IdAgentClass], [IdAgentStatus]);

