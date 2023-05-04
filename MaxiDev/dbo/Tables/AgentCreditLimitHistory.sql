CREATE TABLE [dbo].[AgentCreditLimitHistory] (
    [IdAgentCreditLimitHistory] INT           IDENTITY (1, 1) NOT NULL,
    [IdAgent]                   INT           NOT NULL,
    [CreditAmount]              MONEY         NOT NULL,
    [DateOfLastChange]          DATETIME      NOT NULL,
    [EnterByIdUser]             INT           NOT NULL,
    [NoteCreditAmountChange]    VARCHAR (MAX) NULL,
    CONSTRAINT [PK_AgentCreditLimitHistory] PRIMARY KEY CLUSTERED ([IdAgentCreditLimitHistory] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentCreditLimitHistory_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IX_AgentCreditLimitHistory_IdAgent]
    ON [dbo].[AgentCreditLimitHistory]([IdAgent] ASC);

