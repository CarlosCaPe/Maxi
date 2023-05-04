CREATE TABLE [dbo].[Application] (
    [IdApplication] INT          NOT NULL,
    [Name]          VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_Application] PRIMARY KEY CLUSTERED ([IdApplication] ASC) WITH (FILLFACTOR = 90)
);

