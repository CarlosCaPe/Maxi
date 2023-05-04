CREATE TABLE [dbo].[AgentCommissionPay] (
    [IdAgentCommissionPay]   INT            IDENTITY (1, 1) NOT NULL,
    [AgentCommissionPayName] NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_AgentCommissionPay] PRIMARY KEY CLUSTERED ([IdAgentCommissionPay] ASC) WITH (FILLFACTOR = 90)
);

