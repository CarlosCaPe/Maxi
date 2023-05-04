CREATE TABLE [dbo].[UsersType] (
    [IdUserType] INT           NOT NULL,
    [Name]       VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_UsersType] PRIMARY KEY CLUSTERED ([IdUserType] ASC) WITH (FILLFACTOR = 90)
);

