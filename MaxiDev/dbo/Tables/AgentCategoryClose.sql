CREATE TABLE [dbo].[AgentCategoryClose] (
    [IdAgentCategoryClose] INT          IDENTITY (1, 1) NOT NULL,
    [Description]          VARCHAR (50) NULL,
    CONSTRAINT [PK_AgentReasonClose] PRIMARY KEY CLUSTERED ([IdAgentCategoryClose] ASC)
);

