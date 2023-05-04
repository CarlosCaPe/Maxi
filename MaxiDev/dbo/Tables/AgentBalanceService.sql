CREATE TABLE [dbo].[AgentBalanceService] (
    [IdAgentBalanceService] INT             IDENTITY (1, 1) NOT NULL,
    [Description]           NVARCHAR (2000) NULL,
    [IdGenericStatus]       INT             NULL,
    CONSTRAINT [PK_AgentBalanceService] PRIMARY KEY CLUSTERED ([IdAgentBalanceService] ASC) WITH (FILLFACTOR = 80)
);

