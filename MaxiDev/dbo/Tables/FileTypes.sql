CREATE TABLE [dbo].[FileTypes] (
    [IdFileType] INT          IDENTITY (1, 1) NOT NULL,
    [Extension]  VARCHAR (10) NOT NULL,
    [MimeType]   VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_FileTypes] PRIMARY KEY CLUSTERED ([IdFileType] ASC) WITH (FILLFACTOR = 90)
);

