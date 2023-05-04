CREATE TABLE [dbo].[AgentAppValidStatusTransition] (
    [IdAgentAppValidStatusTransition] INT IDENTITY (1, 1) NOT NULL,
    [FromIdStatus]                    INT NULL,
    [ToIdStatus]                      INT NULL,
    CONSTRAINT [PK_AgentAppValidStatusTransition] PRIMARY KEY CLUSTERED ([IdAgentAppValidStatusTransition] ASC) WITH (FILLFACTOR = 90)
);

