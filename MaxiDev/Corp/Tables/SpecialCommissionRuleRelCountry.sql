CREATE TABLE [Corp].[SpecialCommissionRuleRelCountry] (
    [IdSpecialCommissionRule] INT      NOT NULL,
    [IdCountry]               INT      NOT NULL,
    [CreationDate]            DATETIME NOT NULL,
    [EnterByIdUser]           INT      NOT NULL,
    CONSTRAINT [PK_SpecialCommissionRuleRelCountry] PRIMARY KEY CLUSTERED ([IdSpecialCommissionRule] ASC, [IdCountry] ASC),
    CONSTRAINT [FK_SpecialCommissionRuleRelCountry_EnterByIdUser] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [FK_SpecialCommissionRuleRelCountry_IdCountry] FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[Country] ([IdCountry]),
    CONSTRAINT [FK_SpecialCommissionRuleRelCountry_IdSpecialCommissionRule] FOREIGN KEY ([IdSpecialCommissionRule]) REFERENCES [dbo].[SpecialCommissionRule] ([IdSpecialCommissionRule])
);

