CREATE TABLE [dbo].[UserChangeHistory] (
    [idUser]         INT           NOT NULL,
    [idUserModified] INT           NOT NULL,
    [Date]           DATETIME      NOT NULL,
    [Field]          VARCHAR (100) NOT NULL,
    [Change]         VARCHAR (100) NOT NULL
);

