CREATE TABLE [dbo].[Dashboard] (
    [IdDashboard]     INT          IDENTITY (1, 1) NOT NULL,
    [Idagent]         INT          NULL,
    [AgentState]      NVARCHAR (5) NULL,
    [NumTran]         INT          NULL,
    [AmountInDollars] MONEY        NULL,
    [Date]            DATETIME     NULL,
    CONSTRAINT [PK_Dashboard] PRIMARY KEY CLUSTERED ([IdDashboard] ASC) WITH (FILLFACTOR = 90)
);

