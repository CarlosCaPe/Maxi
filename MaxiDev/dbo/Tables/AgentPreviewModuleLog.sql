CREATE TABLE [dbo].[AgentPreviewModuleLog] (
    [IdAgentPreviewModuleLog] INT           IDENTITY (1, 1) NOT NULL,
    [IdAgentPreviewModule]    INT           NOT NULL,
    [LastValue]               VARCHAR (MAX) NOT NULL,
    [NewValue]                VARCHAR (MAX) NOT NULL,
    [Message]                 VARCHAR (200) NULL,
    [IdUser]                  INT           NOT NULL,
    [CreationDate]            DATETIME      NOT NULL,
    CONSTRAINT [PK_AgentPreviewModuleLog] PRIMARY KEY CLUSTERED ([IdAgentPreviewModuleLog] ASC),
    CONSTRAINT [FK_AgentPreviewModuleLog_AgentPreviewModule] FOREIGN KEY ([IdAgentPreviewModule]) REFERENCES [dbo].[AgentPreviewModule] ([IdAgentPreviewModule]),
    CONSTRAINT [FK_AgentPreviewModuleLog_User] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

