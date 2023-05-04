CREATE TABLE [dbo].[AgentProducts] (
    [IdAgent]         INT NOT NULL,
    [IdGenericStatus] INT NOT NULL,
    [IdOtherProducts] INT NOT NULL,
    CONSTRAINT [PK_AgentProducts] PRIMARY KEY CLUSTERED ([IdAgent] ASC, [IdOtherProducts] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentProductByProvider_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentProductByProvider_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus])
);


GO
CREATE NONCLUSTERED INDEX [IX_AgentProducts_IdGenericStatus_IdOtherProducts]
    ON [dbo].[AgentProducts]([IdGenericStatus] ASC, [IdOtherProducts] ASC)
    INCLUDE([IdAgent]);

