CREATE TABLE [dbo].[AgentSchemaDetailFeeLog] (
    [AgentSchemaDetailFeeLogId] INT      IDENTITY (1, 1) NOT NULL,
    [IdAgentSchema]             INT      NULL,
    [IdPayerConfig]             INT      NULL,
    [IdPreviousFee]             INT      NULL,
    [IdCurrentFee]              INT      NULL,
    [DateOfLastChange]          DATETIME NULL,
    [EnterByIdUser]             INT      NULL,
    [IdAgent]                   INT      NULL,
    CONSTRAINT [PK_AgentSchemaDetailFeeLog] PRIMARY KEY CLUSTERED ([AgentSchemaDetailFeeLogId] ASC)
);

