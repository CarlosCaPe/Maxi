CREATE TABLE [dbo].[AgentCommisionCollection] (
    [IdAgentCommisionCollection]   INT             IDENTITY (1, 1) NOT NULL,
    [IdAgent]                      INT             NOT NULL,
    [Commission]                   MONEY           NOT NULL,
    [DateOfCollection]             DATETIME        NOT NULL,
    [EnterByIdUser]                INT             NULL,
    [Note]                         NVARCHAR (1000) NULL,
    [IdCommisionCollectionConcept] INT             NOT NULL,
    [ApplyDate]                    DATETIME        DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_AgentCommisionCollection] PRIMARY KEY CLUSTERED ([IdAgentCommisionCollection] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentCommisionCollection_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentCommisionCollection_CommisionCollectionConcept] FOREIGN KEY ([IdCommisionCollectionConcept]) REFERENCES [dbo].[CommisionCollectionConcept] ([IdCommisionCollectionConcept])
);


GO
CREATE NONCLUSTERED INDEX [IX_AgentCommisionCollection_IdAgent_DateOfCollection]
    ON [dbo].[AgentCommisionCollection]([IdAgent] ASC, [IdCommisionCollectionConcept] ASC, [DateOfCollection] ASC);

