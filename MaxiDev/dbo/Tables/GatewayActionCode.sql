CREATE TABLE [dbo].[GatewayActionCode] (
    [IdGatewayActionCode] INT           IDENTITY (1, 1) NOT NULL,
    [ActionCode]          VARCHAR (30)  NOT NULL,
    [Description]         VARCHAR (200) NOT NULL,
    [IdStatus]            INT           NOT NULL,
    [IsReverse]           BIT           CONSTRAINT [UQ_GatewayActionCode_IsReverse] DEFAULT ((0)) NOT NULL,
    [IdStatusFromReverse] INT           NULL,
    CONSTRAINT [PK_GatewayActionCode] PRIMARY KEY CLUSTERED ([IdGatewayActionCode] ASC),
    CONSTRAINT [FK_GatewayActionCode_IdStatus] FOREIGN KEY ([IdStatus]) REFERENCES [dbo].[Status] ([IdStatus]),
    CONSTRAINT [FK_GatewayActionCode_IdStatusFromReverse] FOREIGN KEY ([IdStatusFromReverse]) REFERENCES [dbo].[Status] ([IdStatus]),
    CONSTRAINT [UQ_GatewayActionCode_ActionCode] UNIQUE NONCLUSTERED ([ActionCode] ASC)
);

