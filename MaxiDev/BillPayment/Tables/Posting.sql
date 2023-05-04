CREATE TABLE [BillPayment].[Posting] (
    [IdPosting]         INT           IDENTITY (1, 1) NOT NULL,
    [Idaggregator]      INT           NULL,
    [PostingAggregator] VARCHAR (MAX) NULL,
    [PostingMaxi]       VARCHAR (MAX) NULL,
    [BusinnesDay]       BIT           NULL,
    [Notes]             VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([IdPosting] ASC)
);

