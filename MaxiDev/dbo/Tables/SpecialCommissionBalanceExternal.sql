CREATE TABLE [dbo].[SpecialCommissionBalanceExternal] (
    [IdSpecialCommissionBalanceExternal] INT           IDENTITY (1, 1) NOT NULL,
    [IdSpecialCommissionBalance]         INT           NOT NULL,
    [IdExternalRule]                     INT           NOT NULL,
    [Summary]                            VARCHAR (500) NULL,
    [EnterByIdUser]                      INT           NOT NULL,
    CONSTRAINT [PK_SpecialCommissionBalanceExternal] PRIMARY KEY CLUSTERED ([IdSpecialCommissionBalanceExternal] ASC),
    CONSTRAINT [FK_SpecialCommissionBalanceExternal_SpecialCommissionBalance] FOREIGN KEY ([IdSpecialCommissionBalance]) REFERENCES [dbo].[SpecialCommissionBalance] ([IdSpecialCommissionBalance])
);

