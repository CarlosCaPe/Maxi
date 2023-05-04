CREATE TABLE [dbo].[AgentCollectType] (
    [IdAgentCollectType] INT            IDENTITY (1, 1) NOT NULL,
    [Name]               NVARCHAR (MAX) NOT NULL,
    [CreationDate]       DATETIME       NOT NULL,
    [DateofLastChange]   DATETIME       NOT NULL,
    [EnterByIdUser]      INT            NOT NULL,
    [IdStatus]           INT            NOT NULL,
    CONSTRAINT [PK_AgentCollectionType] PRIMARY KEY CLUSTERED ([IdAgentCollectType] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentCollectType_GenericStatus] FOREIGN KEY ([IdStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus])
);

