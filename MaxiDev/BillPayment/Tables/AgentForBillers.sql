CREATE TABLE [BillPayment].[AgentForBillers] (
    [IdAgentForBiller] INT             IDENTITY (1, 1) NOT NULL,
    [IdBiller]         INT             NOT NULL,
    [IdAgent]          INT             NOT NULL,
    [IdFee]            INT             NOT NULL,
    [IdCommission]     INT             NOT NULL,
    [CommionSpecial]   DECIMAL (18, 2) CONSTRAINT [DF__AgentForB__Commi__0CCACB43] DEFAULT ((0)) NULL,
    [DateForCommision] DATETIME        CONSTRAINT [DF__AgentForB__DateF__0DBEEF7C] DEFAULT ('01011900') NULL,
    [IDStatus]         INT             CONSTRAINT [DF__AgentForB__IDSta__0EB313B5] DEFAULT ((0)) NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_AgentForBillers_IdBiller_IdAgent_IDStatus]
    ON [BillPayment].[AgentForBillers]([IdBiller] ASC, [IdAgent] ASC, [IDStatus] ASC);

