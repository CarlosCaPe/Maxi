CREATE TABLE [dbo].[AgentPosTerminal] (
    [IdAgentPosTerminal] INT           IDENTITY (1, 1) NOT NULL,
    [IdPosTerminal]      INT           NOT NULL,
    [IdAgentPosMerchant] INT           NOT NULL,
    [IP]                 VARCHAR (100) NOT NULL,
    [Port]               VARCHAR (100) NOT NULL,
    [IdGenericStatus]    INT           NOT NULL,
    [CreationDate]       DATETIME      NOT NULL,
    [IdUser]             INT           NOT NULL,
    CONSTRAINT [PK_AgentPosTerminal] PRIMARY KEY CLUSTERED ([IdAgentPosTerminal] ASC),
    CONSTRAINT [FK_AgentPosTerminal_AgentPosMerchant] FOREIGN KEY ([IdAgentPosMerchant]) REFERENCES [dbo].[AgentPosMerchant] ([IdAgentPosMerchant]),
    CONSTRAINT [FK_AgentPosTerminal_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_AgentPosTerminal_PosTerminal] FOREIGN KEY ([IdPosTerminal]) REFERENCES [dbo].[PosTerminal] ([IdPosTerminal]),
    CONSTRAINT [FK_AgentPosTerminal_User] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [UQ_AgentPosTerminal_IdAgentPosMerchant_IdPosTerminal] UNIQUE NONCLUSTERED ([IdAgentPosMerchant] ASC, [IdPosTerminal] ASC)
);

