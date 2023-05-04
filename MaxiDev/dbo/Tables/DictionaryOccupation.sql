CREATE TABLE [dbo].[DictionaryOccupation] (
    [Name]         VARCHAR (100)  NOT NULL,
    [NameEs]       NVARCHAR (MAX) NULL,
    [IdOccupation] INT            IDENTITY (1, 1) NOT NULL,
    PRIMARY KEY CLUSTERED ([IdOccupation] ASC)
);

