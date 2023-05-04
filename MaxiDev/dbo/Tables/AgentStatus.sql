CREATE TABLE [dbo].[AgentStatus] (
    [IdAgentStatus]    INT           NOT NULL,
    [AgentStatus]      NVARCHAR (50) NOT NULL,
    [DateOfLastChange] DATETIME      NOT NULL,
    [EnterByIdUser]    INT           NOT NULL,
    [VisibleForUser]   BIT           DEFAULT ((0)) NULL,
    CONSTRAINT [PK_AgentStatus] PRIMARY KEY CLUSTERED ([IdAgentStatus] ASC) WITH (FILLFACTOR = 90)
);

