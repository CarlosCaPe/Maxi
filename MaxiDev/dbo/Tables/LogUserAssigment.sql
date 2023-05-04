CREATE TABLE [dbo].[LogUserAssigment] (
    [IdLogUserAssigment] INT           IDENTITY (1, 1) NOT NULL,
    [IdGroup]            INT           NOT NULL,
    [IdUserAssigment]    INT           NOT NULL,
    [IdUserLastChange]   INT           NOT NULL,
    [Nota]               VARCHAR (MAX) NULL,
    [LastChangeDate]     DATETIME      NOT NULL,
    [TypeChange]         VARCHAR (50)  NULL,
    CONSTRAINT [PK_LogUserAssigment] PRIMARY KEY CLUSTERED ([IdLogUserAssigment] ASC)
);

