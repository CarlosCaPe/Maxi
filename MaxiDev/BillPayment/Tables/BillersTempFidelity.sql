CREATE TABLE [BillPayment].[BillersTempFidelity] (
    [IdBiller]           INT             IDENTITY (1, 1) NOT NULL,
    [Name]               VARCHAR (MAX)   NULL,
    [NameAggregator]     VARCHAR (MAX)   NULL,
    [CutOffTime]         VARCHAR (MAX)   NULL,
    [IdBillerAggregator] INT             NULL,
    [BuyRate]            DECIMAL (18, 2) NULL,
    [Category]           VARCHAR (MAX)   NULL,
    [CategoryAggregator] VARCHAR (MAX)   NULL,
    [Posting]            VARCHAR (MAX)   NULL,
    [PostingAggregator]  VARCHAR (MAX)   NULL,
    [IdStatus]           INT             NULL,
    [Relationship]       VARCHAR (MAX)   NULL
);

