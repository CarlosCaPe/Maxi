CREATE TABLE [dbo].[AgentOtherProduct] (
    [IdAgentOtherProduct] INT IDENTITY (1, 1) NOT NULL,
    [IdAgent]             INT NOT NULL,
    [IdOtherProduct]      INT NOT NULL,
    [IdStatus]            INT NOT NULL,
    [IdAgentLicensedType] INT NOT NULL,
    CONSTRAINT [PK_AgentOtherProduct] PRIMARY KEY CLUSTERED ([IdAgentOtherProduct] ASC),
    CONSTRAINT [FK_AgentOtherProduct_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentOtherProduct_AgentLicensedType] FOREIGN KEY ([IdAgentLicensedType]) REFERENCES [dbo].[AgentLicensedType] ([IdAgentLicensedType]),
    CONSTRAINT [FK_AgentOtherProduct_OtherProducts] FOREIGN KEY ([IdOtherProduct]) REFERENCES [dbo].[OtherProducts] ([IdOtherProducts])
);

