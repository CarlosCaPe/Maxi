CREATE TABLE [dbo].[AgentBalance] (
    [IdAgentBalance] INT            IDENTITY (1, 1) NOT NULL,
    [IdAgent]        INT            NOT NULL,
    [TypeOfMovement] NVARCHAR (MAX) NOT NULL,
    [DateOfMovement] DATETIME       NOT NULL,
    [Amount]         MONEY          NOT NULL,
    [Reference]      NVARCHAR (MAX) NOT NULL,
    [Description]    NVARCHAR (MAX) NOT NULL,
    [Country]        NVARCHAR (MAX) NOT NULL,
    [Commission]     MONEY          NOT NULL,
    [DebitOrCredit]  NVARCHAR (MAX) NOT NULL,
    [Balance]        MONEY          NOT NULL,
    [IdTransfer]     INT            NULL,
    [FxFee]          MONEY          NOT NULL,
    [IsMonthly]      BIT            DEFAULT ((0)) NULL,
    CONSTRAINT [PK_AgentBalance] PRIMARY KEY CLUSTERED ([IdAgentBalance] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentBalance_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent])
);


GO
CREATE NONCLUSTERED INDEX [ixDateOfMovementAgentId]
    ON [dbo].[AgentBalance]([IdAgent] ASC, [DateOfMovement] ASC, [IdAgentBalance] ASC)
    INCLUDE([TypeOfMovement], [Amount], [Reference], [Commission], [FxFee], [Balance]);


GO
CREATE NONCLUSTERED INDEX [IDX_DateOfMovement_AgentId]
    ON [dbo].[AgentBalance]([DateOfMovement] ASC, [IdAgent] ASC);


GO
CREATE NONCLUSTERED INDEX [IX3_agentbalance]
    ON [dbo].[AgentBalance]([IdTransfer] ASC);

