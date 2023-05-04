CREATE TABLE [dbo].[AgentSchema] (
    [IdAgentSchema]       INT            IDENTITY (1, 1) NOT NULL,
    [SchemaName]          NVARCHAR (MAX) NOT NULL,
    [IdFee]               INT            NULL,
    [IdCommission]        INT            NULL,
    [IdCountryCurrency]   INT            NOT NULL,
    [SchemaDefault]       BIT            NOT NULL,
    [DateOfLastChange]    DATETIME       NOT NULL,
    [EnterByIdUser]       INT            NOT NULL,
    [IdGenericStatus]     INT            NOT NULL,
    [Description]         NVARCHAR (MAX) NULL,
    [IdAgent]             INT            NULL,
    [IdAgentSchemaParent] INT            NULL,
    [Spread]              MONEY          DEFAULT ((0)) NOT NULL,
    [EndDateSpread]       DATETIME       NULL,
    CONSTRAINT [PK_AgentSchema] PRIMARY KEY CLUSTERED ([IdAgentSchema] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentSchema_Commission] FOREIGN KEY ([IdCommission]) REFERENCES [dbo].[Commission] ([IdCommission]),
    CONSTRAINT [FK_AgentSchema_CountryCurrency] FOREIGN KEY ([IdCountryCurrency]) REFERENCES [dbo].[CountryCurrency] ([IdCountryCurrency]),
    CONSTRAINT [FK_AgentSchema_Fee] FOREIGN KEY ([IdFee]) REFERENCES [dbo].[Fee] ([IdFee]),
    CONSTRAINT [FK_AgentSchema_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_AgentSchema_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [idxIdcountryCurrency]
    ON [dbo].[AgentSchema]([IdCountryCurrency] ASC, [SchemaDefault] ASC, [IdAgent] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_AgentSchema_IdAgent]
    ON [dbo].[AgentSchema]([IdAgent] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_AgentSchema_SchemaDefault_IdAgent]
    ON [dbo].[AgentSchema]([SchemaDefault] ASC, [IdGenericStatus] ASC, [IdAgent] ASC)
    INCLUDE([IdAgentSchema], [SchemaName], [IdFee], [IdCommission], [IdCountryCurrency], [Description], [Spread], [EndDateSpread]);

