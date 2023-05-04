CREATE TABLE [Soporte].[AgentToCorrect] (
    [IdAgent] INT  NOT NULL,
    [Begin]   DATE NOT NULL,
    CONSTRAINT [PK_AgentToCorrect_IdAgent_Begin] PRIMARY KEY CLUSTERED ([IdAgent] ASC, [Begin] ASC)
);

