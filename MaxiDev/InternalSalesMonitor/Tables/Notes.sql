CREATE TABLE [InternalSalesMonitor].[Notes] (
    [IdNote]        INT           IDENTITY (1, 1) NOT NULL,
    [IdAgent]       INT           NOT NULL,
    [IdNoteType]    INT           NOT NULL,
    [Note]          VARCHAR (250) NOT NULL,
    [EnterByIdUser] INT           NOT NULL,
    [CreationDate]  DATETIME      NOT NULL,
    CONSTRAINT [PK_NoteAgent] PRIMARY KEY CLUSTERED ([IdNote] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Note_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_Note_NoteTypes] FOREIGN KEY ([IdNoteType]) REFERENCES [InternalSalesMonitor].[NoteTypes] ([IdNoteType]),
    CONSTRAINT [FK_Note_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IX_Notes_IdAgent]
    ON [InternalSalesMonitor].[Notes]([IdAgent] ASC);

