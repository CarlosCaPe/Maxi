CREATE TABLE [dbo].[AgentPreviewModule] (
    [IdAgentPreviewModule] INT           IDENTITY (1, 1) NOT NULL,
    [ModuleKey]            VARCHAR (80)  NOT NULL,
    [ModuleName]           VARCHAR (120) NOT NULL,
    CONSTRAINT [PK_AgentPreviewModule] PRIMARY KEY CLUSTERED ([IdAgentPreviewModule] ASC),
    CONSTRAINT [UQ_ModuleKey] UNIQUE NONCLUSTERED ([ModuleKey] ASC)
);

