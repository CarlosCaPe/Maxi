CREATE TABLE [dbo].[LenguageResources] (
    [IdLenguageResource] INT            NOT NULL,
    [MessageES]          NVARCHAR (MAX) NOT NULL,
    [MessageUS]          NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_LenguageResources] PRIMARY KEY CLUSTERED ([IdLenguageResource] ASC) WITH (FILLFACTOR = 90)
);

