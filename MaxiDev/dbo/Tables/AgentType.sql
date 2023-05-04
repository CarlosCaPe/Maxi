CREATE TABLE [dbo].[AgentType] (
    [IdAgentType]      INT           IDENTITY (1, 1) NOT NULL,
    [Name]             NVARCHAR (50) NOT NULL,
    [DateOfLastChange] DATETIME      NOT NULL,
    [EnterByIdUser]    INT           NOT NULL,
    CONSTRAINT [PK_AgentType] PRIMARY KEY CLUSTERED ([IdAgentType] ASC) WITH (FILLFACTOR = 90)
);

