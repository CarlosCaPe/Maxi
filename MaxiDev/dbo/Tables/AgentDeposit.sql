CREATE TABLE [dbo].[AgentDeposit] (
    [IdAgentDeposit]          INT             IDENTITY (1, 1) NOT NULL,
    [IdAgent]                 INT             NOT NULL,
    [IdAgentBalance]          INT             NOT NULL,
    [BankName]                NVARCHAR (MAX)  NOT NULL,
    [Amount]                  MONEY           NOT NULL,
    [DepositDate]             DATETIME        NOT NULL,
    [Notes]                   NVARCHAR (MAX)  NOT NULL,
    [DateOfLastChange]        DATETIME        NOT NULL,
    [EnterByIdUser]           INT             NOT NULL,
    [IdAgentCollectType]      INT             DEFAULT ((4)) NOT NULL,
    [ReferenceNumber]         NVARCHAR (2000) NULL,
    [CodifiedDepositFileName] NVARCHAR (1000) NULL,
    [TypeMovement]            VARCHAR (10)    NULL,
    CONSTRAINT [PK_AgentDeposit] PRIMARY KEY CLUSTERED ([IdAgentDeposit] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentDeposit_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentDeposit_AgentBalance] FOREIGN KEY ([IdAgentBalance]) REFERENCES [dbo].[AgentBalance] ([IdAgentBalance]),
    CONSTRAINT [FK_AgentDeposit_AgentCollectType] FOREIGN KEY ([IdAgentCollectType]) REFERENCES [dbo].[AgentCollectType] ([IdAgentCollectType]),
    CONSTRAINT [FK_AgentDeposit_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IX_AgentDeposit_IdAgent_DepositDate_DateOfLastChange]
    ON [dbo].[AgentDeposit]([IdAgent] ASC, [DateOfLastChange] ASC, [DepositDate] ASC, [IdAgentCollectType] ASC)
    INCLUDE([Amount], [EnterByIdUser], [IdAgentDeposit]);


GO
CREATE NONCLUSTERED INDEX [IX_AgentDeposit_IdAgentBalance_IdAgentCollectType]
    ON [dbo].[AgentDeposit]([IdAgentBalance] ASC, [IdAgentCollectType] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_AgentDeposit_DateOfLastChange]
    ON [dbo].[AgentDeposit]([DateOfLastChange] ASC)
    INCLUDE([IdAgent], [Amount]);

