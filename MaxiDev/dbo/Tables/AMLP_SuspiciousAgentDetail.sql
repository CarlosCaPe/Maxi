CREATE TABLE [dbo].[AMLP_SuspiciousAgentDetail] (
    [IdSuspiciousAgentDetail] INT      IDENTITY (1, 1) NOT NULL,
    [IdSuspiciousAgent]       INT      NOT NULL,
    [IdParameter]             INT      NOT NULL,
    [ParameterValue]          INT      NOT NULL,
    [RiskLevel]               INT      NOT NULL,
    [CreationDate]            DATETIME NOT NULL,
    CONSTRAINT [PK_AMLPSuspiciousAgentDetail] PRIMARY KEY CLUSTERED ([IdSuspiciousAgentDetail] ASC),
    CONSTRAINT [PK_AMLPSuspiciousAgentDetail_AMLPParameter] FOREIGN KEY ([IdParameter]) REFERENCES [dbo].[AMLP_Parameter] ([IdParameter]),
    CONSTRAINT [PK_AMLPSuspiciousAgentDetail_AMLPSuspiciousAgent] FOREIGN KEY ([IdSuspiciousAgent]) REFERENCES [dbo].[AMLP_SuspiciousAgent] ([IdSuspiciousAgent])
);

