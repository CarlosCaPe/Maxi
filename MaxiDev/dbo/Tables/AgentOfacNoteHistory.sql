CREATE TABLE [dbo].[AgentOfacNoteHistory] (
    [IdAgentOfacNoteHistory] INT            IDENTITY (1, 1) NOT NULL,
    [IdAgent]                INT            NOT NULL,
    [IdAgentStatus]          INT            NOT NULL,
    [DateOfMovement]         DATETIME       NOT NULL,
    [Note]                   NVARCHAR (MAX) NOT NULL,
    [DateOfLastChange]       DATETIME       NOT NULL,
    [IdUserLastChange]       INT            NOT NULL,
    [IdType]                 INT            NULL,
    CONSTRAINT [PK_AgentOfacNoteHistory] PRIMARY KEY CLUSTERED ([IdAgentOfacNoteHistory] ASC),
    CONSTRAINT [FK_AgentOfacNoteHistory_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentOfacNoteHistory_Users] FOREIGN KEY ([IdUserLastChange]) REFERENCES [dbo].[Users] ([IdUser])
);

