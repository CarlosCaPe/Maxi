CREATE TABLE [dbo].[AgentBankConfigAccount] (
    [IdConfAgentBank]  INT            IDENTITY (1, 1) NOT NULL,
    [IdAgent]          INT            NOT NULL,
    [IdBank]           INT            NOT NULL,
    [Account]          NVARCHAR (255) NOT NULL,
    [Aba]              NVARCHAR (255) NOT NULL,
    [IdStatus]         INT            NOT NULL,
    [IdUser]           INT            NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    PRIMARY KEY CLUSTERED ([IdConfAgentBank] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_AgentBankConfigAccountg_IdConfAgentBank]
    ON [dbo].[AgentBankConfigAccount]([IdConfAgentBank] ASC);

