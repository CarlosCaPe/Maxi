CREATE TABLE [dbo].[DocumentTypeExceptions] (
    [IdException]  INT           IDENTITY (1, 1) NOT NULL,
    [DocumentType] INT           NULL,
    [StateCode]    VARCHAR (5)   NULL,
    [DocumentPath] VARCHAR (255) NULL
);

