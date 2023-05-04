CREATE TABLE [dbo].[AgentCode] (
    [IdAgentCode] INT IDENTITY (1, 1) NOT NULL,
    [Folio]       INT NOT NULL,
    CONSTRAINT [PK_AgentCode] PRIMARY KEY CLUSTERED ([IdAgentCode] ASC) WITH (FILLFACTOR = 90)
);

