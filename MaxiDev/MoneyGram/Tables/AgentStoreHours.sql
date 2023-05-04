CREATE TABLE [MoneyGram].[AgentStoreHours] (
    [IdAgentStoreHours] INT           IDENTITY (1, 1) NOT NULL,
    [IdAgent]           BIGINT        NULL,
    [DayOfWeek]         VARCHAR (200) NOT NULL,
    [OpenTime]          TIME (7)      NULL,
    [CloseTime]         TIME (7)      NULL,
    [Closed]            BIT           NOT NULL,
    [DateOfLastChange]  DATETIME      NULL,
    [CreationDate]      DATETIME      NOT NULL,
    [Active]            BIT           NOT NULL,
    CONSTRAINT [PK_MoneyGramAgentStoreHours] PRIMARY KEY CLUSTERED ([IdAgentStoreHours] ASC),
    CONSTRAINT [FK_MoneyGramAgentStoreHours_MoneyGramAgent] FOREIGN KEY ([IdAgent]) REFERENCES [MoneyGram].[Agent] ([IdAgent])
);

