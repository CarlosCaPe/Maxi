CREATE TABLE [dbo].[BrokenRulesByTransfer] (
    [IdBrokenRulesByTransfer] INT             IDENTITY (1, 1) NOT NULL,
    [IdTransfer]              INT             NULL,
    [IdKYCAction]             INT             NULL,
    [IsDenyList]              BIT             NULL,
    [MessageInEnglish]        NVARCHAR (MAX)  NULL,
    [MessageInSpanish]        NVARCHAR (MAX)  NULL,
    [IdRule]                  INT             NULL,
    [RuleName]                NVARCHAR (3000) NULL,
    [SSNRequired]             BIT             NULL,
    [IsBlackList]             BIT             NULL,
    [ComplianceFormatId]      INT             NULL,
    CONSTRAINT [PK_BrokenRulesByTransfer] PRIMARY KEY CLUSTERED ([IdBrokenRulesByTransfer] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [fk_ComplianceFormatBrokenRules] FOREIGN KEY ([ComplianceFormatId]) REFERENCES [dbo].[ComplianceFormat] ([ComplianceFormatId])
);


GO
CREATE NONCLUSTERED INDEX [BrokenRulesByTransferIdTransferIdKYCAction]
    ON [dbo].[BrokenRulesByTransfer]([IdTransfer] ASC, [IdKYCAction] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_BrokenRulesByTransfer_ComplianceFormatId]
    ON [dbo].[BrokenRulesByTransfer]([ComplianceFormatId] ASC)
    INCLUDE([IdTransfer]);

