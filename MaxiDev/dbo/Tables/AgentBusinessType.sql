CREATE TABLE [dbo].[AgentBusinessType] (
    [IdAgentBusinessType] INT            IDENTITY (1, 1) NOT NULL,
    [Name]                NVARCHAR (MAX) NOT NULL,
    [DateOfLastChange]    DATETIME       NOT NULL,
    CONSTRAINT [PK_AgentBusinessType_1] PRIMARY KEY CLUSTERED ([IdAgentBusinessType] ASC)
);

