CREATE TABLE [dbo].[AMLP_SuspiciousAgentCurrent] (
    [IdSuspiciousAgentCurrent] INT IDENTITY (1, 1) NOT NULL,
    [IdAgent]                  INT NOT NULL,
    [IdCountry]                INT NOT NULL,
    [IdSuspiciousAgent]        INT NOT NULL,
    CONSTRAINT [PK_AMLPSuspiciousAgentCurrent] PRIMARY KEY CLUSTERED ([IdSuspiciousAgentCurrent] ASC),
    CONSTRAINT [FK_AMLPSuspiciousAgentCurrent_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AMLPSuspiciousAgentCurrent_AMLPSuspiciousAgent] FOREIGN KEY ([IdSuspiciousAgent]) REFERENCES [dbo].[AMLP_SuspiciousAgent] ([IdSuspiciousAgent]),
    CONSTRAINT [FK_AMLPSuspiciousAgentCurrent_Country] FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[Country] ([IdCountry]),
    CONSTRAINT [UQ_AMLPSuspiciousAgentCurrent] UNIQUE NONCLUSTERED ([IdAgent] ASC, [IdCountry] ASC)
);

