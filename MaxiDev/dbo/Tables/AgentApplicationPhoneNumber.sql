CREATE TABLE [dbo].[AgentApplicationPhoneNumber] (
    [IdAgentApplicationPhoneNumber] INT            IDENTITY (1, 1) NOT NULL,
    [IdAgentApplication]            INT            NOT NULL,
    [PhoneNumber]                   NVARCHAR (MAX) NOT NULL,
    [Comment]                       NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_AgentApplicationPhoneNumber] PRIMARY KEY CLUSTERED ([IdAgentApplicationPhoneNumber] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentApplicationPhoneNumber_AgentApplications] FOREIGN KEY ([IdAgentApplication]) REFERENCES [dbo].[AgentApplications] ([IdAgentApplication])
);

