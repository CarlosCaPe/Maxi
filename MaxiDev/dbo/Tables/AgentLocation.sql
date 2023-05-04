CREATE TABLE [dbo].[AgentLocation] (
    [idAgentLocation]  INT            IDENTITY (1, 1) NOT NULL,
    [idAgent]          INT            NULL,
    [latitude]         NVARCHAR (80)  NOT NULL,
    [length]           NVARCHAR (80)  NOT NULL,
    [addressFormatted] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_AgentLocation] PRIMARY KEY CLUSTERED ([idAgentLocation] ASC),
    CONSTRAINT [FK_AgentLocation_Agent] FOREIGN KEY ([idAgent]) REFERENCES [dbo].[Agent] ([IdAgent]) NOT FOR REPLICATION
);


GO
ALTER TABLE [dbo].[AgentLocation] NOCHECK CONSTRAINT [FK_AgentLocation_Agent];

