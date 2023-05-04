CREATE TABLE [dbo].[PosSettlementGiftTotal] (
    [IdPosSettlementGiftTotal] INT           IDENTITY (1, 1) NOT NULL,
    [IdPosSettlement]          INT           NOT NULL,
    [ActivationAmount]         VARCHAR (200) NOT NULL,
    [ActivationCount]          VARCHAR (200) NOT NULL,
    [Amount]                   VARCHAR (200) NOT NULL,
    [Count]                    VARCHAR (200) NOT NULL,
    [RedemptionAmount]         VARCHAR (200) NOT NULL,
    [RedemptionCount]          VARCHAR (200) NOT NULL,
    [RefundAmount]             VARCHAR (200) NOT NULL,
    [RefundCount]              VARCHAR (200) NOT NULL,
    [ReloadAmount]             VARCHAR (200) NOT NULL,
    [ReloadCount]              VARCHAR (200) NOT NULL,
    [ZerocardAmount]           VARCHAR (200) NOT NULL,
    [ZerocardCount]            VARCHAR (200) NOT NULL,
    CONSTRAINT [PK_PosSettlementGiftTotal] PRIMARY KEY CLUSTERED ([IdPosSettlementGiftTotal] ASC),
    CONSTRAINT [FK_PosSettlementGiftTotal_PosSettlement] FOREIGN KEY ([IdPosSettlement]) REFERENCES [dbo].[PosSettlement] ([IdPosSettlement])
);

