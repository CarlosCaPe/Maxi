CREATE TABLE [dbo].[DictionaryLastName] (
    [LastName] VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_DictionaryLastName] PRIMARY KEY CLUSTERED ([LastName] ASC) WITH (FILLFACTOR = 90)
);

