CREATE TABLE [dbo].[AgentPaymentSchema] (
    [IdAgentPaymentSchema] INT            IDENTITY (1, 1) NOT NULL,
    [PaymentName]          NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_AgentPaymentSchema] PRIMARY KEY CLUSTERED ([IdAgentPaymentSchema] ASC) WITH (FILLFACTOR = 90)
);

