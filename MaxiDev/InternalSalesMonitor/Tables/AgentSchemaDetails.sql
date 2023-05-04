CREATE TABLE [InternalSalesMonitor].[AgentSchemaDetails] (
    [IdAgentSchemaDetail] INT      NOT NULL,
    [IsEnabled]           BIT      DEFAULT ((0)) NULL,
    [EnterByIdUser]       INT      NOT NULL,
    [DateOfLastChange]    DATETIME NULL,
    CONSTRAINT [FK_AgentSchemaDetails_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [UQ_AgentSchemaDetails] UNIQUE NONCLUSTERED ([IdAgentSchemaDetail] ASC)
);

