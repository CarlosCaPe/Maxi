CREATE TABLE [dbo].[AgentCreditApproval] (
    [IdAgentCreditApproval] INT      IDENTITY (1, 1) NOT NULL,
    [IdAgent]               INT      NOT NULL,
    [CreditLimit]           MONEY    NULL,
    [CreditLimitSuggested]  MONEY    NULL,
    [IsApproved]            BIT      NULL,
    [CreationDate]          DATETIME NULL,
    [DateOfLastChange]      DATETIME NULL,
    [EnterByIdUser]         INT      NOT NULL,
    CONSTRAINT [PK_CreditApproval] PRIMARY KEY CLUSTERED ([IdAgentCreditApproval] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentCreditApproval_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentCreditApproval_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [ix_AgentCreditApproval_IdAgent_IsApproved]
    ON [dbo].[AgentCreditApproval]([IsApproved] ASC)
    INCLUDE([IdAgentCreditApproval], [CreditLimit], [CreditLimitSuggested], [IdAgent]);


GO
CREATE NONCLUSTERED INDEX [IX_AgentCreditApproval_IdAgent_IsApproved_DateOfLastChange]
    ON [dbo].[AgentCreditApproval]([IdAgent] ASC, [IsApproved] ASC, [DateOfLastChange] ASC);

