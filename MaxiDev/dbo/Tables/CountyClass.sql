CREATE TABLE [dbo].[CountyClass] (
    [IdCountyClass]    INT            NOT NULL,
    [CountyClassName]  NVARCHAR (100) NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    CONSTRAINT [PK_CountyClass] PRIMARY KEY CLUSTERED ([IdCountyClass] ASC) WITH (FILLFACTOR = 90)
);

