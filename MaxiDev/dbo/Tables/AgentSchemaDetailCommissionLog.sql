CREATE TABLE [dbo].[AgentSchemaDetailCommissionLog] (
    [AgentSchemaDetailCommissionLogId] INT      IDENTITY (1, 1) NOT NULL,
    [IdAgentSchema]                    INT      NULL,
    [IdPayerConfig]                    INT      NULL,
    [IdPreviousCommission]             INT      NULL,
    [IdCurrentCommission]              INT      NULL,
    [DateOfLastChange]                 DATETIME NULL,
    [EnterByIdUser]                    INT      NULL,
    [IdAgent]                          INT      NULL,
    CONSTRAINT [PK_AgentSchemaDetailCommissionLog] PRIMARY KEY CLUSTERED ([AgentSchemaDetailCommissionLogId] ASC)
);

