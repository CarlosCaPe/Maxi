CREATE TABLE [BillPayment].[ResPonseCodesAggregator] (
    [IdResponse]   INT            IDENTITY (1, 1) NOT NULL,
    [IdAggregator] INT            NOT NULL,
    [ReturnCode]   NVARCHAR (255) DEFAULT ('') NOT NULL,
    [Message]      NVARCHAR (255) DEFAULT ('') NOT NULL,
    [IdStatusMaxi] INT            NOT NULL,
    [TypeMovent]   NVARCHAR (255) DEFAULT ('') NOT NULL,
    [MessageEsp]   NVARCHAR (255) DEFAULT (' ') NOT NULL,
    PRIMARY KEY CLUSTERED ([IdResponse] ASC),
    FOREIGN KEY ([IdAggregator]) REFERENCES [BillPayment].[Aggregator] ([IdAggregator])
);

