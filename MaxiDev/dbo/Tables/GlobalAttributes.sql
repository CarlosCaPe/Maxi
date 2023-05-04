CREATE TABLE [dbo].[GlobalAttributes] (
    [Name]        NVARCHAR (50)  NOT NULL,
    [Value]       NVARCHAR (MAX) NOT NULL,
    [Description] NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_GlobalAttributes] PRIMARY KEY CLUSTERED ([Name] ASC) WITH (FILLFACTOR = 90)
);

