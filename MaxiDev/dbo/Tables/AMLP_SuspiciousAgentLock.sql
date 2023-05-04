CREATE TABLE [dbo].[AMLP_SuspiciousAgentLock] (
    [IdAgent]               INT      NOT NULL,
    [IdCountry]             INT      NOT NULL,
    [IdUser]                INT      NOT NULL,
    [CreationDate]          DATETIME NOT NULL,
    [LastUpdate]            DATETIME NOT NULL,
    [IdSuspiciousAgentLock] AS       (concat([IdAgent],'-',[IdCountry])),
    CONSTRAINT [PK_AMLPSuspiciousAgentLock] PRIMARY KEY CLUSTERED ([IdSuspiciousAgentLock] ASC),
    CONSTRAINT [FK_AMLPSuspiciousAgentLock_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AMLPSuspiciousAgentLock_Country] FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[Country] ([IdCountry]),
    CONSTRAINT [FK_AMLPSuspiciousAgentLock_Users] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

