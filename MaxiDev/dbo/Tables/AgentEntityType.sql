CREATE TABLE [dbo].[AgentEntityType] (
    [IdAgentEntityType] INT           IDENTITY (1, 1) NOT NULL,
    [Name]              NVARCHAR (50) NULL,
    [DateOfLastChange]  DATETIME      NULL,
    CONSTRAINT [PK_AgentEntityType] PRIMARY KEY CLUSTERED ([IdAgentEntityType] ASC)
);

