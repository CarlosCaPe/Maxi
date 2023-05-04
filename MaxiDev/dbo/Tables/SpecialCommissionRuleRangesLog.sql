CREATE TABLE [dbo].[SpecialCommissionRuleRangesLog] (
    [IdLogDetail]                  INT      IDENTITY (1, 1) NOT NULL,
    [IdLog]                        INT      NULL,
    [IdSpecialCommissionRuleRange] INT      NOT NULL,
    [IdSpecialCommissionRule]      INT      NOT NULL,
    [Commission]                   MONEY    NOT NULL,
    [Goal]                         INT      NOT NULL,
    [From]                         INT      NOT NULL,
    [To]                           INT      NOT NULL,
    [DateOfLastChange]             DATETIME NOT NULL,
    [EnterByIdUser]                INT      NOT NULL,
    CONSTRAINT [PK_SpecialCommissionRuleRangesLog] PRIMARY KEY CLUSTERED ([IdLogDetail] ASC),
    CONSTRAINT [FK_SpecialCommissionRuleRangesLog_SpecialCommissionRuleLog] FOREIGN KEY ([IdLog]) REFERENCES [dbo].[SpecialCommissionRuleLog] ([IdLog])
);

