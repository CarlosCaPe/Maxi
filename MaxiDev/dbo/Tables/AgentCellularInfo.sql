CREATE TABLE [dbo].[AgentCellularInfo] (
    [IdAgent]                     INT NOT NULL,
    [IdCommissionByOtherProducts] INT NOT NULL,
    CONSTRAINT [PK_AgentCellularInfo] PRIMARY KEY CLUSTERED ([IdAgent] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentCellularInfo_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentCellularInfo_CommissionByProvider] FOREIGN KEY ([IdCommissionByOtherProducts]) REFERENCES [dbo].[CommissionByOtherProducts] ([IdCommissionByOtherProducts])
);

