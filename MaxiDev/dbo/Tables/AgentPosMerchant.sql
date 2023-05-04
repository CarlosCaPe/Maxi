CREATE TABLE [dbo].[AgentPosMerchant] (
    [IdAgentPosMerchant] INT           IDENTITY (1, 1) NOT NULL,
    [IdAgentPosAccount]  INT           NOT NULL,
    [MerchantId]         VARCHAR (100) NOT NULL,
    [IdGenericStatus]    INT           NOT NULL,
    [CreationDate]       DATETIME      NOT NULL,
    [IdUser]             INT           NOT NULL,
    CONSTRAINT [PK_AgentPosMerchant] PRIMARY KEY CLUSTERED ([IdAgentPosMerchant] ASC),
    CONSTRAINT [FK_AgentPosMerchant_AgentPosAccount] FOREIGN KEY ([IdAgentPosAccount]) REFERENCES [dbo].[AgentPosAccount] ([IdAgentPosAccount]),
    CONSTRAINT [FK_AgentPosMerchant_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_AgentPosMerchant_User] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

