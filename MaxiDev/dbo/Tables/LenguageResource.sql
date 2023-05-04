CREATE TABLE [dbo].[LenguageResource] (
    [IdLenguageResource] INT            IDENTITY (1, 1) NOT NULL,
    [IdLenguage]         INT            NOT NULL,
    [MessageKey]         NVARCHAR (150) NOT NULL,
    [Message]            NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_LenguageResource] PRIMARY KEY CLUSTERED ([IdLenguageResource] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_LenguageResource_Lenguage] FOREIGN KEY ([IdLenguage]) REFERENCES [dbo].[Lenguage] ([IdLenguage])
);

