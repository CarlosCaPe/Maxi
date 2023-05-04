CREATE TABLE [dbo].[AgentCollectionConcept] (
    [IdAgentCollectionConcept] INT            IDENTITY (1, 1) NOT NULL,
    [Name]                     NVARCHAR (MAX) NOT NULL,
    [CreationDate]             DATETIME       NOT NULL,
    [DateofLastChange]         DATETIME       NOT NULL,
    [EnterByIdUser]            INT            NOT NULL,
    [IdStatus]                 INT            NOT NULL,
    CONSTRAINT [PK_IdAgentCollectionConcept] PRIMARY KEY CLUSTERED ([IdAgentCollectionConcept] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentCollectionConcept_GenericStatus] FOREIGN KEY ([IdStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus])
);

