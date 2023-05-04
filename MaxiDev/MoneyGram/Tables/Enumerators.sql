CREATE TABLE [MoneyGram].[Enumerators] (
    [IdEnumerator]     INT           IDENTITY (1, 1) NOT NULL,
    [IdEnumeratedType] INT           NOT NULL,
    [Label]            VARCHAR (200) NOT NULL,
    [Value]            VARCHAR (200) NOT NULL,
    [DateOfLastChange] DATETIME      NULL,
    [CreationDate]     DATETIME      NOT NULL,
    [Active]           BIT           NOT NULL,
    CONSTRAINT [PK_MoneyGramEnumerators] PRIMARY KEY CLUSTERED ([IdEnumerator] ASC),
    CONSTRAINT [FK_MoneyGramEnumerators_MoneyGramEnumeratedType] FOREIGN KEY ([IdEnumeratedType]) REFERENCES [MoneyGram].[EnumeratedType] ([IdEnumeratedType])
);

