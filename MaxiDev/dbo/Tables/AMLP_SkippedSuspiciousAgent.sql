CREATE TABLE [dbo].[AMLP_SkippedSuspiciousAgent] (
    [IdAgent]     INT            NOT NULL,
    [IdCountry]   INT            NOT NULL,
    [DateStopped] DATETIME       NOT NULL,
    [DateResume]  DATETIME       NOT NULL,
    [IdUser]      INT            NULL,
    [Notes]       VARCHAR (1000) NULL,
    CONSTRAINT [FK_AMLPSkippedSuspiciousAgent_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AMLPSkippedSuspiciousAgent_Country] FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[Country] ([IdCountry]),
    CONSTRAINT [FK_AMLPSkippedSuspiciousAgent_User] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

