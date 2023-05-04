CREATE TABLE [dbo].[AgentSchemaDetail] (
    [IdAgentSchemaDetail] INT      IDENTITY (1, 1) NOT NULL,
    [IdAgentSchema]       INT      NOT NULL,
    [IdPayerConfig]       INT      NOT NULL,
    [SpreadValue]         MONEY    NOT NULL,
    [DateOfLastChange]    DATETIME NOT NULL,
    [EnterByIdUser]       INT      NOT NULL,
    [IdFee]               INT      NULL,
    [IdCommission]        INT      NULL,
    [TempSpread]          MONEY    NULL,
    [EndDateTempSpread]   DATETIME NULL,
    [IdSpread]            INT      NULL,
    CONSTRAINT [PK_SchemaDetail] PRIMARY KEY CLUSTERED ([IdAgentSchemaDetail] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentSchemaDetail_Commission] FOREIGN KEY ([IdCommission]) REFERENCES [dbo].[Commission] ([IdCommission]),
    CONSTRAINT [FK_AgentSchemaDetail_Fee] FOREIGN KEY ([IdFee]) REFERENCES [dbo].[Fee] ([IdFee]),
    CONSTRAINT [FK_AgentSchemaDetail_PayerConfig] FOREIGN KEY ([IdPayerConfig]) REFERENCES [dbo].[PayerConfig] ([IdPayerConfig]),
    CONSTRAINT [FK_AgentSchemaDetail_Spread] FOREIGN KEY ([IdSpread]) REFERENCES [dbo].[Spread] ([IdSpread]),
    CONSTRAINT [FK_SchemaDetail_AgentSchema] FOREIGN KEY ([IdAgentSchema]) REFERENCES [dbo].[AgentSchema] ([IdAgentSchema])
);


GO
CREATE NONCLUSTERED INDEX [IX_AgentSchemaDetail_IdAgentSchema_IdPayerConfig]
    ON [dbo].[AgentSchemaDetail]([IdAgentSchema] ASC, [IdPayerConfig] ASC)
    INCLUDE([IdAgentSchemaDetail], [SpreadValue], [TempSpread], [EndDateTempSpread], [IdSpread]);


GO
CREATE NONCLUSTERED INDEX [IX_AgentSchemaDetail_IdPayerConfig]
    ON [dbo].[AgentSchemaDetail]([IdPayerConfig] ASC, [IdAgentSchema] ASC)
    INCLUDE([DateOfLastChange], [IdAgentSchemaDetail], [SpreadValue], [EnterByIdUser], [IdCommission], [TempSpread], [EndDateTempSpread], [IdSpread]);

