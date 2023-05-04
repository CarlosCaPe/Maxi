CREATE TABLE [dbo].[Location_BK191001] (
    [idLocation]   INT            IDENTITY (1, 1) NOT NULL,
    [idCountry]    INT            NULL,
    [idState]      INT            NULL,
    [idCity]       INT            NULL,
    [LocationName] VARCHAR (2000) NULL,
    [AL1]          VARCHAR (2000) NULL,
    [AL2]          VARCHAR (2000) NULL,
    [AL3]          VARCHAR (2000) NULL
);

