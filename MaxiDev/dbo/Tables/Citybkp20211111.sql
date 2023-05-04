CREATE TABLE [dbo].[Citybkp20211111] (
    [IdCity]           INT            IDENTITY (1, 1) NOT NULL,
    [IdState]          INT            NOT NULL,
    [CityName]         NVARCHAR (MAX) NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL
);

