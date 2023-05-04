CREATE TABLE [dbo].[CheckNoteType] (
    [IdCheckNoteType] INT           IDENTITY (1, 1) NOT NULL,
    [CheckNoteType]   VARCHAR (MAX) NULL,
    CONSTRAINT [PK_CheckNoteType] PRIMARY KEY CLUSTERED ([IdCheckNoteType] ASC)
);

