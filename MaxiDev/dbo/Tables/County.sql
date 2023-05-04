CREATE TABLE [dbo].[County] (
    [IdCounty]         INT            IDENTITY (1, 1) NOT NULL,
    [IdState]          INT            NOT NULL,
    [CountyName]       NVARCHAR (100) NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    CONSTRAINT [PK_County] PRIMARY KEY CLUSTERED ([IdCounty] ASC) WITH (FILLFACTOR = 90)
);

