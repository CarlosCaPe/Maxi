CREATE TABLE [dbo].[LogAgentSchemaSpread] (
    [IdLogAgentSchemaSpread] INT      IDENTITY (1, 1) NOT NULL,
    [IdAgentSchema]          INT      NOT NULL,
    [IdAgent]                INT      NOT NULL,
    [Spread]                 MONEY    NOT NULL,
    [EndDateSpread]          DATETIME NOT NULL,
    [EnterByIdUser]          INT      NOT NULL,
    [EnterDate]              DATETIME NOT NULL,
    CONSTRAINT [FK_LogAgentSchemaSpread_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

