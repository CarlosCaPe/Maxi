CREATE TABLE [dbo].[MaxiCollectionDetail] (
    [IdMaxiCollectionDetail] INT      IDENTITY (1, 1) NOT NULL,
    [IdAgent]                INT      NULL,
    [DateOfCollection]       DATETIME NULL,
    [DateOfDebit]            DATETIME NULL,
    [DateOfLNPD]             DATETIME NULL,
    CONSTRAINT [PK_IdMaxiCollectionDetail] PRIMARY KEY CLUSTERED ([IdMaxiCollectionDetail] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_MaxiCollectionDetail_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent])
);


GO
CREATE NONCLUSTERED INDEX [MaxiCollectionDetailDateOfCollectionIncludeIdAgentDateOfDebitDateOfLNPD]
    ON [dbo].[MaxiCollectionDetail]([DateOfCollection] ASC)
    INCLUDE([IdAgent], [DateOfDebit], [DateOfLNPD]) WITH (FILLFACTOR = 90);

