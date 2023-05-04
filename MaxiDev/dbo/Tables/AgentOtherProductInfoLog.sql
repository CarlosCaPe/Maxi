CREATE TABLE [dbo].[AgentOtherProductInfoLog] (
    [IdAgentOtherProductInfoLog] INT      IDENTITY (1, 1) NOT NULL,
    [IdAgent]                    INT      NOT NULL,
    [Detail]                     XML      NOT NULL,
    [CreateDate]                 DATETIME CONSTRAINT [DF_AgentOtherProductInfoLog_CreateDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_AgentOtherProductInfoLog] PRIMARY KEY CLUSTERED ([IdAgentOtherProductInfoLog] ASC)
);

