CREATE TABLE [dbo].[ACHMovement_BK20200116] (
    [IdACHMovement]       INT            IDENTITY (1, 1) NOT NULL,
    [IdACHSummary]        INT            NOT NULL,
    [IdAgent]             INT            NOT NULL,
    [ReferenceAmount]     MONEY          NULL,
    [Amount]              MONEY          NULL,
    [Note]                NVARCHAR (MAX) NULL,
    [AmountByCalendar]    MONEY          NULL,
    [AmountByLastDay]     MONEY          NULL,
    [AmountByCollectPlan] MONEY          NULL,
    [IsManual]            BIT            NOT NULL
);

