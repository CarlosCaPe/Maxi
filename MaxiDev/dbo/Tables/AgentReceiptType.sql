CREATE TABLE [dbo].[AgentReceiptType] (
    [IdAgentReceiptType] INT            IDENTITY (1, 1) NOT NULL,
    [Name]               NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_AgentReceiptType] PRIMARY KEY CLUSTERED ([IdAgentReceiptType] ASC) WITH (FILLFACTOR = 90)
);

