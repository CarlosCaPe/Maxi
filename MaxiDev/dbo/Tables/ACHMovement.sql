CREATE TABLE [dbo].[ACHMovement] (
    [IdACHMovement]       INT            IDENTITY (1, 1) NOT NULL,
    [IdACHSummary]        INT            NOT NULL,
    [IdAgent]             INT            NOT NULL,
    [ReferenceAmount]     MONEY          NULL,
    [Amount]              MONEY          NULL,
    [Note]                NVARCHAR (MAX) NULL,
    [AmountByCalendar]    MONEY          NULL,
    [AmountByLastDay]     MONEY          NULL,
    [AmountByCollectPlan] MONEY          NULL,
    [IsManual]            BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ACHMovement] PRIMARY KEY CLUSTERED ([IdACHMovement] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ACHMovement_ACHSummary] FOREIGN KEY ([IdACHSummary]) REFERENCES [dbo].[ACHSummary] ([IdACHSummary])
);


GO
CREATE NONCLUSTERED INDEX [IX_ACHMovement_IdACHSummary]
    ON [dbo].[ACHMovement]([IdACHSummary] ASC, [IsManual] ASC)
    INCLUDE([IdACHMovement], [IdAgent], [ReferenceAmount], [Amount], [AmountByCalendar], [AmountByLastDay], [AmountByCollectPlan], [Note]);

