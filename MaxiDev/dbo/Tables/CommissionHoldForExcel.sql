CREATE TABLE [dbo].[CommissionHoldForExcel] (
    [GuidIdentifier]    VARCHAR (100)  NOT NULL,
    [CreationDate]      DATETIME       DEFAULT (getdate()) NOT NULL,
    [UserId]            INT            NOT NULL,
    [AgentId]           INT            NOT NULL,
    [AgentCode]         NVARCHAR (MAX) NULL,
    [AgentName]         NVARCHAR (MAX) NULL,
    [AgentClass]        NVARCHAR (MAX) NULL,
    [TotalCommission]   MONEY          NULL,
    [SpecialCommission] MONEY          NULL,
    [RetainCommission]  MONEY          NULL,
    [MonthlyCommission] MONEY          NULL,
    [Debt]              MONEY          NULL,
    [Amount]            MONEY          NULL,
    [Notes]             NVARCHAR (MAX) NULL,
    [BonusApplied]      MONEY          NULL,
    [BonusDebt]         MONEY          NULL
);

