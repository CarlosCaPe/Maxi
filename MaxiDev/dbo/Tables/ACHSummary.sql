CREATE TABLE [dbo].[ACHSummary] (
    [IdACHSummary]       INT      IDENTITY (1, 1) NOT NULL,
    [ACHDate]            DATE     NOT NULL,
    [CreationDate]       DATETIME NOT NULL,
    [DateofLastChange]   DATETIME NULL,
    [ApplyDate]          DATETIME NULL,
    [EnterByIdUser]      INT      NOT NULL,
    [IdAgentCollectType] INT      NOT NULL,
    CONSTRAINT [PK_ACHSummary] PRIMARY KEY CLUSTERED ([IdACHSummary] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ACHSummary_AgentCollectType] FOREIGN KEY ([IdAgentCollectType]) REFERENCES [dbo].[AgentCollectType] ([IdAgentCollectType])
);

