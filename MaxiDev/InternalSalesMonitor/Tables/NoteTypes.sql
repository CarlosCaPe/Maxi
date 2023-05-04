CREATE TABLE [InternalSalesMonitor].[NoteTypes] (
    [IdNoteType] INT           IDENTITY (1, 1) NOT NULL,
    [NoteType]   VARCHAR (100) NOT NULL,
    PRIMARY KEY CLUSTERED ([IdNoteType] ASC)
);

