CREATE TABLE [dbo].[AgentCollectionDetail] (
    [IdAgentCollectionDetail]  INT            IDENTITY (1, 1) NOT NULL,
    [IdAgentCollection]        INT            NOT NULL,
    [LastAmountToPay]          MONEY          NOT NULL,
    [ActualAmountToPay]        MONEY          NOT NULL,
    [AmountToPay]              MONEY          NOT NULL,
    [AmountExpected]           MONEY          NULL,
    [Note]                     NVARCHAR (MAX) NULL,
    [IdAgentCollectionConcept] INT            NOT NULL,
    [CreationDate]             DATETIME       NOT NULL,
    [DateofLastChange]         DATETIME       NOT NULL,
    [EnterByIdUser]            INT            NOT NULL,
    CONSTRAINT [PK_IdAgentCollectionDetail] PRIMARY KEY CLUSTERED ([IdAgentCollectionDetail] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentCollectionDetail_AgentCollection] FOREIGN KEY ([IdAgentCollection]) REFERENCES [dbo].[AgentCollection] ([IdAgentCollection]),
    CONSTRAINT [FK_AgentCollectionDetail_IdAgentCollectionConcept] FOREIGN KEY ([IdAgentCollectionConcept]) REFERENCES [dbo].[AgentCollectionConcept] ([IdAgentCollectionConcept])
);


GO
CREATE NONCLUSTERED INDEX [IX1_AgentCollectionDetail]
    ON [dbo].[AgentCollectionDetail]([CreationDate] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_AgentCollectionDetail_IdAgentCollection_DateofLastChange]
    ON [dbo].[AgentCollectionDetail]([IdAgentCollection] ASC, [DateofLastChange] ASC)
    INCLUDE([IdAgentCollectionDetail], [ActualAmountToPay]);


GO
CREATE NONCLUSTERED INDEX [IX_AgentCollectionDetail_DateofLastChange]
    ON [dbo].[AgentCollectionDetail]([DateofLastChange] ASC)
    INCLUDE([IdAgentCollection], [AmountToPay]);

