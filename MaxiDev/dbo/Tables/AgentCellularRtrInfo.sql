CREATE TABLE [dbo].[AgentCellularRtrInfo] (
    [IdAgent]                     INT NOT NULL,
    [IdCommissionByOtherProducts] INT NOT NULL,
    PRIMARY KEY CLUSTERED ([IdAgent] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [CellularRtrAgentInfo_SelectedAgent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [CellularRtrAgentInfo_SelectedCommission] FOREIGN KEY ([IdCommissionByOtherProducts]) REFERENCES [dbo].[CommissionByOtherProducts] ([IdCommissionByOtherProducts])
);

