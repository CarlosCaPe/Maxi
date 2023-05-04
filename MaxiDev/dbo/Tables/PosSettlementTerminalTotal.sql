CREATE TABLE [dbo].[PosSettlementTerminalTotal] (
    [IdPosSettlementTerminalTotal] INT           IDENTITY (1, 1) NOT NULL,
    [IdPosSettlement]              INT           NOT NULL,
    [CashbackAmount]               VARCHAR (200) NOT NULL,
    [RefundAmount]                 VARCHAR (200) NOT NULL,
    [RefundCount]                  VARCHAR (200) NOT NULL,
    [SaleAmount]                   VARCHAR (200) NOT NULL,
    [SaleCount]                    VARCHAR (200) NOT NULL,
    [SurchargeAmount]              VARCHAR (200) NOT NULL,
    [TipAmount]                    VARCHAR (200) NOT NULL,
    [TotalAmount]                  VARCHAR (200) NOT NULL,
    [TotalCount]                   VARCHAR (200) NOT NULL,
    [VoidAmount]                   VARCHAR (200) NOT NULL,
    [VoidCashbackAmount]           VARCHAR (200) NOT NULL,
    [VoidCount]                    VARCHAR (200) NOT NULL,
    [VoidSurchargeAmount]          VARCHAR (200) NOT NULL,
    [VoidTipAmount]                VARCHAR (200) NOT NULL,
    CONSTRAINT [PK_PosSettlementTerminalTotal] PRIMARY KEY CLUSTERED ([IdPosSettlementTerminalTotal] ASC),
    CONSTRAINT [FK_PosSettlementTerminalTotal_PosSettlement] FOREIGN KEY ([IdPosSettlement]) REFERENCES [dbo].[PosSettlement] ([IdPosSettlement])
);

