CREATE TABLE [dbo].[AMLP_SuspiciousAgent] (
    [IdSuspiciousAgent]    INT      IDENTITY (1, 1) NOT NULL,
    [IdAgent]              INT      NOT NULL,
    [IdCountry]            INT      NOT NULL,
    [NumberOfTransactions] INT      NOT NULL,
    [RiskLevel]            INT      NOT NULL,
    [HoldTransactions]     BIT      NOT NULL,
    [CreationDate]         DATETIME NOT NULL,
    CONSTRAINT [PK_AMLPSuspiciousAgent] PRIMARY KEY CLUSTERED ([IdSuspiciousAgent] ASC),
    CONSTRAINT [FK_AMLPSuspiciousAgent_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AMLPSuspiciousAgent_Country] FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[Country] ([IdCountry])
);

