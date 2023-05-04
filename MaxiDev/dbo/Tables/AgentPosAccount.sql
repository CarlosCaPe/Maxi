CREATE TABLE [dbo].[AgentPosAccount] (
    [IdAgentPosAccount] INT           IDENTITY (1, 1) NOT NULL,
    [IdAgent]           INT           NOT NULL,
    [AccountNumber]     VARCHAR (100) NOT NULL,
    [IdGenericStatus]   INT           NOT NULL,
    [CreationDate]      DATETIME      NOT NULL,
    [IdUser]            INT           NOT NULL,
    CONSTRAINT [PK_AgentPosAccount] PRIMARY KEY CLUSTERED ([IdAgentPosAccount] ASC),
    CONSTRAINT [FK_AgentPosAccount_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentPosAccount_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_AgentPosAccount_User] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [UQ_AgentPosAccount_AccountNumber] UNIQUE NONCLUSTERED ([AccountNumber] ASC)
);

