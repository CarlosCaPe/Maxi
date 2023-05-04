CREATE TABLE [dbo].[AgentReasonClose] (
    [IdReasonClose]        INT          IDENTITY (1, 1) NOT NULL,
    [IdAgentCategoryClose] INT          NOT NULL,
    [Description]          VARCHAR (70) NULL,
    CONSTRAINT [PK_AgentReasonCloses] PRIMARY KEY CLUSTERED ([IdReasonClose] ASC),
    CONSTRAINT [FK_AgentReasonClose_AgentCategoryClose] FOREIGN KEY ([IdAgentCategoryClose]) REFERENCES [dbo].[AgentCategoryClose] ([IdAgentCategoryClose])
);

