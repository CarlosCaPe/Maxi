CREATE TABLE [dbo].[AMLP_SuspiciousKYCHoldReason] (
    [Id]   INT           IDENTITY (1, 1) NOT NULL,
    [Name] VARCHAR (200) NULL,
    CONSTRAINT [PK_AMLPSuspiciusKYCHoldReason] PRIMARY KEY CLUSTERED ([Id] ASC)
);

