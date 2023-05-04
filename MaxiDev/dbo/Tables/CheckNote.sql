CREATE TABLE [dbo].[CheckNote] (
    [IdCheckNote]     INT           IDENTITY (1, 1) NOT NULL,
    [IdCheckDetail]   INT           NOT NULL,
    [IdCheckNoteType] INT           NOT NULL,
    [IdUser]          INT           NOT NULL,
    [Note]            VARCHAR (MAX) NOT NULL,
    [EnterDate]       DATETIME      NOT NULL,
    CONSTRAINT [PK_CheckNote] PRIMARY KEY CLUSTERED ([IdCheckNote] ASC),
    CONSTRAINT [FK_CheckNote_CheckDetails] FOREIGN KEY ([IdCheckDetail]) REFERENCES [dbo].[CheckDetails] ([IdCheckDetail]),
    CONSTRAINT [FK_CheckNote_CheckNoteType] FOREIGN KEY ([IdCheckNoteType]) REFERENCES [dbo].[CheckNoteType] ([IdCheckNoteType]),
    CONSTRAINT [FK_CheckNote_Users] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

