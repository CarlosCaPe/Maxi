CREATE TABLE [dbo].[AgentCommunication] (
    [IdAgentCommunication] INT           IDENTITY (1, 1) NOT NULL,
    [Communication]        NVARCHAR (50) NOT NULL,
    [DateOfLastChange]     DATETIME      NOT NULL,
    [EnterByIdUser]        INT           NOT NULL,
    CONSTRAINT [PK_AgentCommunication] PRIMARY KEY CLUSTERED ([IdAgentCommunication] ASC) WITH (FILLFACTOR = 90)
);

