CREATE TABLE [dbo].[AgentApplicationStatusHistory] (
    [IdAgentApplicationStatusHistory] INT            IDENTITY (1, 1) NOT NULL,
    [IdAgentApplication]              INT            NOT NULL,
    [IdAgentApplicationStatus]        INT            NOT NULL,
    [DateOfMovement]                  DATETIME       NOT NULL,
    [Note]                            NVARCHAR (MAX) NOT NULL,
    [DateOfLastChange]                DATETIME       NOT NULL,
    [IdUserLastChange]                INT            NOT NULL,
    [IdType]                          INT            NULL,
    CONSTRAINT [PK_AgentApplicationStatusHistory] PRIMARY KEY CLUSTERED ([IdAgentApplicationStatusHistory] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentApplicationStatusHistory_AgentApplications] FOREIGN KEY ([IdAgentApplication]) REFERENCES [dbo].[AgentApplications] ([IdAgentApplication]),
    CONSTRAINT [FK_AgentApplicationStatusHistory_Users] FOREIGN KEY ([IdUserLastChange]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [ix_AgentApplicationStatusHistory_IdAgentApplication]
    ON [dbo].[AgentApplicationStatusHistory]([IdAgentApplication] ASC);

