CREATE TABLE [dbo].[CheckNoteNotification] (
    [idCheckNoteNotificationId] INT IDENTITY (1, 1) NOT NULL,
    [idCheckNote]               INT NOT NULL,
    [idMessage]                 INT NULL,
    [idGenericStatus]           INT NOT NULL,
    CONSTRAINT [PK_CheckNoteNotification] PRIMARY KEY CLUSTERED ([idCheckNoteNotificationId] ASC)
);

