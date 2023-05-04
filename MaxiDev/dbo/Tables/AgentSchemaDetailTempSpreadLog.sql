CREATE TABLE [dbo].[AgentSchemaDetailTempSpreadLog] (
    [AgentSchemaDetailTempSpreadLogId] INT      IDENTITY (1, 1) NOT NULL,
    [IdAgentSchema]                    INT      NULL,
    [IdPayerConfig]                    INT      NULL,
    [PreviousTempSpread]               MONEY    NULL,
    [PreviousEndDateTempSpread]        DATETIME NULL,
    [CurrentTempSpread]                MONEY    NULL,
    [CurrentEndDateTempSpread]         DATETIME NULL,
    [DateOfLastChange]                 DATETIME NULL,
    [EnterByIdUser]                    INT      NULL,
    [IdAgent]                          INT      NULL,
    CONSTRAINT [PK_AgentSchemaDetailTempSpreadLog] PRIMARY KEY CLUSTERED ([AgentSchemaDetailTempSpreadLogId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_AgentSchemaDetailTempSpreadLog_IdAgentSchema_IdPayerConfig_includes]
    ON [dbo].[AgentSchemaDetailTempSpreadLog]([IdAgentSchema] ASC, [IdPayerConfig] ASC)
    INCLUDE([CurrentTempSpread], [CurrentEndDateTempSpread], [DateOfLastChange], [EnterByIdUser]);

