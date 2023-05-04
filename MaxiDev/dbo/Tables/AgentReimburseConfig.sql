CREATE TABLE [dbo].[AgentReimburseConfig] (
    [IdAgentReimburseConfig] INT      IDENTITY (1, 1) NOT NULL,
    [IdAgent]                INT      NOT NULL,
    [Goal]                   INT      NOT NULL,
    [DateOfLastChange]       DATETIME NOT NULL,
    [UserChange]             INT      NOT NULL,
    [StatusActive]           BIT      NOT NULL,
    CONSTRAINT [PK_AgentReimburseConfig] PRIMARY KEY CLUSTERED ([IdAgentReimburseConfig] ASC)
);


GO
CREATE NONCLUSTERED INDEX [idxIdAgentStatusActive]
    ON [dbo].[AgentReimburseConfig]([IdAgent] ASC, [StatusActive] ASC);

