CREATE TABLE [dbo].[BrokenRulesByPretransfer] (
    [IdBrokenRulesByPretransfer] INT             IDENTITY (1, 1) NOT NULL,
    [IdPretransfer]              INT             NULL,
    [IdKYCAction]                INT             NULL,
    [IsDenyList]                 BIT             NULL,
    [MessageInEnglish]           NVARCHAR (MAX)  NULL,
    [MessageInSpanish]           NVARCHAR (MAX)  NULL,
    [IdRule]                     INT             NULL,
    [RuleName]                   NVARCHAR (3000) NULL,
    [SSNRequired]                BIT             NULL,
    [IsBlackList]                BIT             NULL,
    [ComplianceFormatId]         INT             NULL,
    PRIMARY KEY CLUSTERED ([IdBrokenRulesByPretransfer] ASC),
    FOREIGN KEY ([ComplianceFormatId]) REFERENCES [dbo].[ComplianceFormat] ([ComplianceFormatId])
);

