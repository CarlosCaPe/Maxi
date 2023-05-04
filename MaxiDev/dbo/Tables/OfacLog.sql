CREATE TABLE [dbo].[OfacLog] (
    [IdOfacLog] INT            IDENTITY (1, 1) NOT NULL,
    [process]   NVARCHAR (MAX) NULL,
    [RunDate]   DATETIME       NULL,
    CONSTRAINT [PK_OfacLog] PRIMARY KEY CLUSTERED ([IdOfacLog] ASC) WITH (FILLFACTOR = 90)
);

