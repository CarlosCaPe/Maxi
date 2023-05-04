CREATE TABLE [dbo].[GatewayActionCodeAggregator] (
    [IdGatewayActionCodeAggregator] INT           IDENTITY (1, 1) NOT NULL,
    [ActionCode]                    VARCHAR (30)  NOT NULL,
    [Description]                   VARCHAR (200) NOT NULL,
    [IdStatus]                      INT           NOT NULL,
    [IsReverse]                     BIT           CONSTRAINT [UQ_GatewayActionCodeAggregator_IsReverse] DEFAULT ((0)) NOT NULL,
    [IdStatusFromReverse]           INT           NULL,
    CONSTRAINT [PK_GatewayActionCodeAggregator] PRIMARY KEY CLUSTERED ([IdGatewayActionCodeAggregator] ASC),
    CONSTRAINT [FK_GatewayActionCodeAggregator_IdStatus] FOREIGN KEY ([IdStatus]) REFERENCES [dbo].[Status] ([IdStatus]),
    CONSTRAINT [FK_GatewayActionCodeAggregator_IdStatusFromReverse] FOREIGN KEY ([IdStatusFromReverse]) REFERENCES [dbo].[Status] ([IdStatus]),
    CONSTRAINT [UQ_GatewayActionCodeAggregator_ActionCode] UNIQUE NONCLUSTERED ([ActionCode] ASC)
);

