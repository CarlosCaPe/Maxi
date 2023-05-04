CREATE TABLE [dbo].[CheckCredit] (
    [IdCheckCredit] INT          IDENTITY (1, 1) NOT NULL,
    [IdAgent]       INT          NOT NULL,
    [SubAccount]    VARCHAR (50) NOT NULL,
    [Amount]        MONEY        NOT NULL,
    [IdStatus]      INT          NOT NULL,
    [CreateDate]    DATETIME     NOT NULL,
    [IdCheckBundle] INT          NULL,
    CONSTRAINT [PK_CheckCredit] PRIMARY KEY CLUSTERED ([IdCheckCredit] ASC),
    CONSTRAINT [FK_CheckCredit_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent])
);

