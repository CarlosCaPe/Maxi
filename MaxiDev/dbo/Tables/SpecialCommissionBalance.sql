CREATE TABLE [dbo].[SpecialCommissionBalance] (
    [IdSpecialCommissionBalance] INT      IDENTITY (1, 1) NOT NULL,
    [IdAgent]                    INT      NOT NULL,
    [DateOfMovement]             DATETIME NOT NULL,
    [Commission]                 MONEY    NOT NULL,
    [IdSpecialCommissionRule]    INT      NOT NULL,
    [DateOfApplication]          DATETIME NOT NULL,
    CONSTRAINT [PK_SpecialCommissionBalance] PRIMARY KEY CLUSTERED ([IdSpecialCommissionBalance] ASC),
    CONSTRAINT [FK_SpecialCommissionBalance_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent])
);


GO
CREATE NONCLUSTERED INDEX [IX_SpecialCommissionBalance_IdAgent_DateOfApplication]
    ON [dbo].[SpecialCommissionBalance]([IdAgent] ASC, [DateOfApplication] ASC)
    INCLUDE([Commission], [IdSpecialCommissionRule]);


GO
CREATE NONCLUSTERED INDEX [IX_SpecialCommissionBalance_DateOfApplication]
    ON [dbo].[SpecialCommissionBalance]([DateOfApplication] ASC)
    INCLUDE([IdAgent], [Commission]);

