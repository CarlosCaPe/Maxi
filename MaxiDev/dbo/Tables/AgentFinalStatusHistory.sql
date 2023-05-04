CREATE TABLE [dbo].[AgentFinalStatusHistory] (
    [IdAgentFinalStatusHistory] INT      IDENTITY (1, 1) NOT NULL,
    [IdAgent]                   INT      NOT NULL,
    [IdAgentStatus]             INT      NOT NULL,
    [DateOfAgentStatus]         DATETIME NOT NULL,
    [IdAgentCommissionPay]      INT      NULL,
    CONSTRAINT [PK_AgentFinalStatusHistory] PRIMARY KEY CLUSTERED ([IdAgentFinalStatusHistory] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentFinalStatusHistory_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentFinalStatusHistory_Agentstatus] FOREIGN KEY ([IdAgentStatus]) REFERENCES [dbo].[AgentStatus] ([IdAgentStatus])
);


GO
CREATE NONCLUSTERED INDEX [ix_AgentFinalStatusHistory]
    ON [dbo].[AgentFinalStatusHistory]([DateOfAgentStatus] ASC)
    INCLUDE([IdAgent], [IdAgentStatus], [IdAgentCommissionPay]);

