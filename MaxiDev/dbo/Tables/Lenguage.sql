CREATE TABLE [dbo].[Lenguage] (
    [IdLenguage] INT            IDENTITY (1, 1) NOT NULL,
    [Name]       NVARCHAR (150) NOT NULL,
    [Culture]    NVARCHAR (150) NOT NULL,
    CONSTRAINT [PK_Lenguage] PRIMARY KEY CLUSTERED ([IdLenguage] ASC) WITH (FILLFACTOR = 90)
);

