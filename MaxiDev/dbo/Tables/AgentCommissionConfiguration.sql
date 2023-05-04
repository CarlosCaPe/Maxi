CREATE TABLE [dbo].[AgentCommissionConfiguration] (
    [IdAgentCollection]    INT   NOT NULL,
    [CommissionPercentage] INT   NOT NULL,
    [CommisionMoney]       MONEY DEFAULT ((0)) NOT NULL,
    [IsPercent]            BIT   DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_IdAgentCollection] PRIMARY KEY CLUSTERED ([IdAgentCollection] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentCommissionConfiguration_AgentCollection] FOREIGN KEY ([IdAgentCollection]) REFERENCES [dbo].[AgentCollection] ([IdAgentCollection])
);

