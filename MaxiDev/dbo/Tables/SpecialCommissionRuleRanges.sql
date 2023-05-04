CREATE TABLE [dbo].[SpecialCommissionRuleRanges] (
    [IdSpecialCommissionRuleRange] INT      IDENTITY (1, 1) NOT NULL,
    [IdSpecialCommissionRule]      INT      NOT NULL,
    [Commission]                   MONEY    NOT NULL,
    [Goal]                         INT      NOT NULL,
    [From]                         INT      NOT NULL,
    [To]                           INT      NOT NULL,
    [DateOfLastChange]             DATETIME NOT NULL,
    [EnterByIdUser]                INT      NOT NULL,
    CONSTRAINT [PK_SpecialCommissionHybrid] PRIMARY KEY CLUSTERED ([IdSpecialCommissionRuleRange] ASC)
);

