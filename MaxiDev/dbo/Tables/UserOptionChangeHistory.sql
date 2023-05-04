CREATE TABLE [dbo].[UserOptionChangeHistory] (
    [idUser]         INT          NULL,
    [idUserModified] INT          NOT NULL,
    [Change]         VARCHAR (50) NOT NULL,
    [idAction]       INT          NOT NULL,
    [Date]           DATETIME     NOT NULL
);

