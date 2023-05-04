CREATE TABLE [MoneyGram].[TransactionOtherFields] (
    [IdTransactionOtherFields] INT           IDENTITY (1, 1) NOT NULL,
    [IdTransaction]            INT           NOT NULL,
    [XmlTag]                   VARCHAR (100) NOT NULL,
    [Value]                    VARCHAR (200) NOT NULL,
    CONSTRAINT [PK_MoneyGramTransactionOtherFields] PRIMARY KEY CLUSTERED ([IdTransactionOtherFields] ASC),
    CONSTRAINT [FK_MoneyGramTransactionOtherFields_MoneyGramTransaction] FOREIGN KEY ([IdTransaction]) REFERENCES [MoneyGram].[Transaction] ([IdTransaction])
);

