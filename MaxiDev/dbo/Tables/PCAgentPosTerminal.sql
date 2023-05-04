CREATE TABLE [dbo].[PCAgentPosTerminal] (
    [IdPCAgentPosTerminal] INT      IDENTITY (1, 1) NOT NULL,
    [IdPcIdentifier]       INT      NOT NULL,
    [IdAgentPosTerminal]   INT      NOT NULL,
    [IdGenericStatus]      INT      NOT NULL,
    [CreationDate]         DATETIME NOT NULL,
    [IdUser]               INT      NOT NULL,
    CONSTRAINT [PK_PCAgentPosTerminal] PRIMARY KEY CLUSTERED ([IdPCAgentPosTerminal] ASC),
    CONSTRAINT [FK_PCAgentPosTerminal_AgentPosTerminal] FOREIGN KEY ([IdAgentPosTerminal]) REFERENCES [dbo].[AgentPosTerminal] ([IdAgentPosTerminal]),
    CONSTRAINT [FK_PCAgentPosTerminal_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_PCAgentPosTerminal_PcIdentifier] FOREIGN KEY ([IdPcIdentifier]) REFERENCES [dbo].[PcIdentifier] ([IdPcIdentifier]),
    CONSTRAINT [FK_PCAgentPosTerminal_User] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

