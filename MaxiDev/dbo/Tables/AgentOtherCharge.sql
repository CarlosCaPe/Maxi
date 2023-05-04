CREATE TABLE [dbo].[AgentOtherCharge] (
    [IdAgentOtherCharge]   INT            IDENTITY (1, 1) NOT NULL,
    [IdAgent]              INT            NOT NULL,
    [IdAgentBalance]       INT            NOT NULL,
    [Amount]               MONEY          NOT NULL,
    [ChargeDate]           DATETIME       NOT NULL,
    [Notes]                NVARCHAR (MAX) NOT NULL,
    [DateOfLastChange]     DATETIME       NOT NULL,
    [EnterByIdUser]        INT            NOT NULL,
    [IdOtherChargesMemo]   INT            DEFAULT ((15)) NOT NULL,
    [OtherChargesMemoNote] NVARCHAR (MAX) NULL,
    [IsReverse]            BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AgentOtherCredit] PRIMARY KEY CLUSTERED ([IdAgentOtherCharge] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentOtherCharge_OtherChargesMemo] FOREIGN KEY ([IdOtherChargesMemo]) REFERENCES [dbo].[OtherChargesMemo] ([IdOtherChargesMemo]),
    CONSTRAINT [FK_AgentOtherCharge_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [FK_AgentOtherCredit_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentOtherCredit_AgentBalance] FOREIGN KEY ([IdAgentBalance]) REFERENCES [dbo].[AgentBalance] ([IdAgentBalance])
);


GO
CREATE NONCLUSTERED INDEX [IX_AgentOtherCharge_IdAgent_Amount_ChargeDate]
    ON [dbo].[AgentOtherCharge]([IdAgent] ASC, [Amount] ASC, [ChargeDate] ASC)
    INCLUDE([IdAgentOtherCharge], [IdAgentBalance], [Notes], [DateOfLastChange], [EnterByIdUser], [IdOtherChargesMemo], [IsReverse]);


GO
CREATE NONCLUSTERED INDEX [IX_AgentOtherCharge_IdOtherChargesMemo]
    ON [dbo].[AgentOtherCharge]([IdOtherChargesMemo] ASC)
    INCLUDE([IdAgent], [IdAgentBalance]);

