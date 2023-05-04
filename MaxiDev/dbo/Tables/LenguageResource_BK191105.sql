CREATE TABLE [dbo].[LenguageResource_BK191105] (
    [IdLenguageResource] INT            IDENTITY (1, 1) NOT NULL,
    [IdLenguage]         INT            NOT NULL,
    [MessageKey]         NVARCHAR (150) NOT NULL,
    [Message]            NVARCHAR (MAX) NOT NULL
);

