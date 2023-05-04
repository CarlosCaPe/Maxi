CREATE TABLE [MoneyGram].[EnumeratorMap] (
    [IdEnumeratorMap] INT           IDENTITY (1, 1) NOT NULL,
    [IdEnumerator]    INT           NOT NULL,
    [IdReference]     VARCHAR (200) NULL,
    CONSTRAINT [FK_MoneyGramEnumeratorMap] PRIMARY KEY CLUSTERED ([IdEnumeratorMap] ASC),
    CONSTRAINT [FK_MoneyGramEnumeratorMap_MoneyGramEnumerators] FOREIGN KEY ([IdEnumerator]) REFERENCES [MoneyGram].[Enumerators] ([IdEnumerator])
);

