CREATE TABLE [dbo].[CollectPlanForExcel] (
    [GuidIdentifier]           VARCHAR (100)  NOT NULL,
    [CreationDate]             DATETIME       DEFAULT (getdate()) NOT NULL,
    [UserId]                   INT            NOT NULL,
    [AgentCollectionId]        INT            NOT NULL,
    [AgentCode]                NVARCHAR (MAX) NULL,
    [AgentName]                NVARCHAR (MAX) NULL,
    [Percentage]               INT            NULL,
    [Commission]               MONEY          NULL,
    [ExpectedAmount]           MONEY          NULL,
    [Amount]                   MONEY          NULL,
    [Note]                     NVARCHAR (MAX) NULL,
    [AgentClass]               NVARCHAR (MAX) NULL,
    [Fee]                      MONEY          NULL,
    [TotalDebt]                MONEY          NULL,
    [FixedCommission]          MONEY          NULL,
    [SpecialCommission]        MONEY          NULL,
    [SpecialCommissionToApply] MONEY          NULL,
    [BonusApplied]             MONEY          NULL,
    [BonusDebt]                MONEY          NULL
);

