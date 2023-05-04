CREATE TABLE [MoneyGram].[EnumeratedType] (
    [IdEnumeratedType] INT           IDENTITY (1, 1) NOT NULL,
    [FieldName]        VARCHAR (200) NOT NULL,
    [ReferenceTable]   VARCHAR (200) NOT NULL,
    [DateOfLastChange] DATETIME      NULL,
    [CreationDate]     DATETIME      NOT NULL,
    [Active]           BIT           NOT NULL,
    CONSTRAINT [PK_MoneyGramEnumeratedType] PRIMARY KEY CLUSTERED ([IdEnumeratedType] ASC),
    CONSTRAINT [UQ_MoneyGramEnumeratedType] UNIQUE NONCLUSTERED ([FieldName] ASC)
);

