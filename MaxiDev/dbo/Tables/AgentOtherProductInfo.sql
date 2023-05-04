CREATE TABLE [dbo].[AgentOtherProductInfo] (
    [IdAgentOtherProductInfo]     INT   IDENTITY (1, 1) NOT NULL,
    [IdAgent]                     INT   NOT NULL,
    [IdOtherProduct]              INT   NOT NULL,
    [AmountForAgent]              MONEY DEFAULT ((0)) NOT NULL,
    [IdFeeByOtherProducts]        INT   NULL,
    [IdCommissionByOtherProducts] INT   NULL,
    CONSTRAINT [PK_AgentOtherProductInfo] PRIMARY KEY CLUSTERED ([IdAgentOtherProductInfo] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentOtherProductInfo_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentOtherProductInfo_CommissionByProvider] FOREIGN KEY ([IdCommissionByOtherProducts]) REFERENCES [dbo].[CommissionByOtherProducts] ([IdCommissionByOtherProducts]),
    CONSTRAINT [FK_AgentOtherProductInfo_FeeByProvider] FOREIGN KEY ([IdFeeByOtherProducts]) REFERENCES [dbo].[FeeByOtherProducts] ([IdFeeByOtherProducts]),
    CONSTRAINT [FK_AgentOtherProductInfo_OtherProduct] FOREIGN KEY ([IdOtherProduct]) REFERENCES [dbo].[OtherProducts] ([IdOtherProducts])
);


GO
CREATE NONCLUSTERED INDEX [IX_AgentOtherProductInfo_IdAgent_IdOtherProduct]
    ON [dbo].[AgentOtherProductInfo]([IdAgent] ASC, [IdOtherProduct] ASC);

