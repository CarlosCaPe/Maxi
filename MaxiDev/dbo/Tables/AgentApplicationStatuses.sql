CREATE TABLE [dbo].[AgentApplicationStatuses] (
    [IdAgentApplicationStatus] INT            IDENTITY (1, 1) NOT NULL,
    [StatusCodeName]           NVARCHAR (MAX) NOT NULL,
    [StatusName]               NVARCHAR (MAX) NOT NULL,
    [VisibleForUser]           BIT            NOT NULL,
    [DateOfLastChange]         DATETIME       NOT NULL,
    [IdUserLastChange]         INT            NOT NULL,
    [IsHold]                   BIT            NULL,
    CONSTRAINT [PK_AgentApplicationStatuses] PRIMARY KEY CLUSTERED ([IdAgentApplicationStatus] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentApplicationStatuses_Users] FOREIGN KEY ([IdUserLastChange]) REFERENCES [dbo].[Users] ([IdUser])
);

