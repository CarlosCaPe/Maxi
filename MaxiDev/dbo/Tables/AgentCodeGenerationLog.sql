CREATE TABLE [dbo].[AgentCodeGenerationLog] (
    [IdAgentCodeGenerationLog] INT            IDENTITY (1, 1) NOT NULL,
    [AgentCode]                NVARCHAR (MAX) NULL,
    [EnterByIdUser]            INT            NULL,
    [DateOfCreation]           DATETIME       NULL,
    CONSTRAINT [PK_AgentCodeGenerationLog] PRIMARY KEY CLUSTERED ([IdAgentCodeGenerationLog] ASC) WITH (FILLFACTOR = 90)
);

