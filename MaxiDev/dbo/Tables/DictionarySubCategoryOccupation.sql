CREATE TABLE [dbo].[DictionarySubCategoryOccupation] (
    [IdSubOccupation] INT            IDENTITY (1, 1) NOT NULL,
    [Name]            VARCHAR (100)  NOT NULL,
    [NameEs]          NVARCHAR (MAX) NULL,
    [IdOccupation]    INT            NULL,
    FOREIGN KEY ([IdOccupation]) REFERENCES [dbo].[DictionaryOccupation] ([IdOccupation])
);

