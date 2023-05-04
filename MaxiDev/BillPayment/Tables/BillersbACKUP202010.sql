﻿CREATE TABLE [BillPayment].[BillersbACKUP202010] (
    [IdBiller]           INT             IDENTITY (1, 1) NOT NULL,
    [Name]               VARCHAR (MAX)   NULL,
    [NameAggregator]     VARCHAR (MAX)   NULL,
    [IdAggregator]       VARCHAR (MAX)   NULL,
    [Posting]            VARCHAR (MAX)   NULL,
    [PostingAggregator]  VARCHAR (MAX)   NULL,
    [BuyRate]            DECIMAL (5, 2)  NULL,
    [Relationship]       VARCHAR (MAX)   NULL,
    [CutOffTime]         VARCHAR (MAX)   NULL,
    [IdStatus]           INT             NULL,
    [IdBillerOfClone]    INT             DEFAULT ((0)) NULL,
    [IdBillerAggregator] INT             NULL,
    [CommBiller]         DECIMAL (18, 2) DEFAULT ((0)) NULL,
    [Category]           VARCHAR (MAX)   DEFAULT ('') NULL,
    [CategoryAggregator] VARCHAR (MAX)   DEFAULT ('') NULL,
    [IsDomestic]         BIT             NULL,
    [ChoiseData]         VARCHAR (250)   NULL,
    [CancelAllowed]      BIT             DEFAULT ((0)) NULL,
    [BillerInstructions] VARCHAR (500)   NULL,
    [IsFixedFee]         BIT             DEFAULT ((0)) NOT NULL,
    [MsrpFee]            DECIMAL (5, 2)  DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([IdBiller] ASC)
);

