CREATE TABLE [dbo].[AgentAdditionalEmail] (
    [IdAgentAdditionalEmail] INT           IDENTITY (1, 1) NOT NULL,
    [IdAgent]                INT           NOT NULL,
    [EmailAddress]           VARCHAR (100) NOT NULL,
    [EmailAlias]             VARCHAR (200) NOT NULL,
    [IdCreationUser]         INT           NOT NULL,
    [CreationDate]           DATETIME      NOT NULL,
    [IdUserLastChange]       INT           NULL,
    [DateOfLastChange]       DATETIME      NULL,
    [IdGenericStatus]        INT           NOT NULL,
    PRIMARY KEY CLUSTERED ([IdAgentAdditionalEmail] ASC),
    CONSTRAINT [FK_AgentAdditionalEmailAgent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentAdditionalEmailGenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_AgentAdditionalEmailUsers] FOREIGN KEY ([IdCreationUser]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [FK_AgentAdditionalEmailUsers1] FOREIGN KEY ([IdUserLastChange]) REFERENCES [dbo].[Users] ([IdUser])
);

