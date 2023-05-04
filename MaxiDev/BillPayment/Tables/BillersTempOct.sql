CREATE TABLE [BillPayment].[BillersTempOct] (
    [Name]               VARCHAR (MAX)   NULL,
    [NameAggregator]     VARCHAR (MAX)   NULL,
    [CutOffTime]         VARCHAR (MAX)   NULL,
    [IdBillerAggregator] INT             NULL,
    [BuyRate]            DECIMAL (18, 2) NULL,
    [Category]           VARCHAR (MAX)   NULL,
    [CategoryAggregator] VARCHAR (MAX)   NULL,
    [Posting]            VARCHAR (MAX)   NULL,
    [PostingAggregator]  VARCHAR (MAX)   NULL,
    [Relationship]       VARCHAR (MAX)   NULL,
    [IdStatus]           INT             NULL,
    [choiseData]         VARCHAR (MAX)   NULL,
    [idAggregator]       INT             NULL,
    [cancelAllowed]      BIT             NULL,
    [billerInstructions] VARCHAR (500)   NULL,
    [isFixedFee]         BIT             NULL,
    [msrpFee]            DECIMAL (18, 2) NULL
);

