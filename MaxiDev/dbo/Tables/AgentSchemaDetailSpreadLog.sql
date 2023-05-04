CREATE TABLE [dbo].[AgentSchemaDetailSpreadLog] (
    [AgentSchemaDetailSpreadLogId] INT      IDENTITY (1, 1) NOT NULL,
    [IdAgentSchema]                INT      NULL,
    [IdPayerConfig]                INT      NULL,
    [IdPreviousSpreadValue]        INT      NULL,
    [PreviousSpreadValue]          MONEY    NULL,
    [IdCurrentSpreadValue]         INT      NULL,
    [CurrentSpreadValue]           MONEY    NULL,
    [DateOfLastChange]             DATETIME NULL,
    [EnterByIdUser]                INT      NULL,
    CONSTRAINT [PK_AgentSchemaDetailSpreadLog] PRIMARY KEY CLUSTERED ([AgentSchemaDetailSpreadLogId] ASC)
);

