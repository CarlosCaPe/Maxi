CREATE TABLE [dbo].[CommisionCollectionConcept] (
    [IdCommisionCollectionConcept] INT            IDENTITY (1, 1) NOT NULL,
    [Name]                         NVARCHAR (100) NULL,
    [DateOfLastChange]             DATETIME       NOT NULL,
    [EnterByIdUser]                INT            NOT NULL,
    CONSTRAINT [PK_CommisionCollectionConcept] PRIMARY KEY CLUSTERED ([IdCommisionCollectionConcept] ASC) WITH (FILLFACTOR = 90)
);

