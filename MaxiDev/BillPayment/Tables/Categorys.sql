CREATE TABLE [BillPayment].[Categorys] (
    [IdCategory]         INT           IDENTITY (1, 1) NOT NULL,
    [Idaggregator]       INT           NULL,
    [CategoryAggregator] VARCHAR (MAX) NULL,
    [CategoryMaxi]       VARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([IdCategory] ASC)
);

