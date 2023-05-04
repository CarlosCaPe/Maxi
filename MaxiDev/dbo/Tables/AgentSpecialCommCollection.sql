CREATE TABLE [dbo].[AgentSpecialCommCollection] (
    [IdAgentSpecialCommCollection] BIGINT         IDENTITY (1, 1) NOT NULL,
    [IdAgent]                      INT            NOT NULL,
    [SpecialCommission]            MONEY          NOT NULL,
    [DateOfCollection]             DATETIME       NOT NULL,
    [EnterByUserId]                INT            NOT NULL,
    [Note]                         NVARCHAR (MAX) NULL,
    [ApplyDate]                    DATETIME       DEFAULT (getdate()) NOT NULL,
    [SpecialCommissionConceptId]   INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([IdAgentSpecialCommCollection] ASC),
    FOREIGN KEY ([EnterByUserId]) REFERENCES [dbo].[Users] ([IdUser]),
    FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    FOREIGN KEY ([SpecialCommissionConceptId]) REFERENCES [dbo].[SpecialCommissionConcept] ([SpecialCommissionConceptId])
);

