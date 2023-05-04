CREATE TABLE [BillPayment].[Aggregator] (
    [IdAggregator]    INT           IDENTITY (1, 1) NOT NULL,
    [Name]            VARCHAR (MAX) NULL,
    [Description]     VARCHAR (MAX) NULL,
    [IdOtherProducts] INT           NULL,
    [IdStatus]        INT           NULL,
    PRIMARY KEY CLUSTERED ([IdAggregator] ASC)
);

