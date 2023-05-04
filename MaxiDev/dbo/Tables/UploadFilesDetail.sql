CREATE TABLE [dbo].[UploadFilesDetail] (
    [IdUploadFileDetail]  INT IDENTITY (1, 1) NOT NULL,
    [IdUploadFile]        INT NOT NULL,
    [IdDocumentImageType] INT NOT NULL,
    [IdCountry]           INT NULL,
    [IdState]             INT NULL,
    CONSTRAINT [PK_[UploadFilesDetail] PRIMARY KEY CLUSTERED ([IdUploadFileDetail] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_UploadFilesDetail_DocumentImageType] FOREIGN KEY ([IdDocumentImageType]) REFERENCES [dbo].[DocumentImageType] ([IdDocumentImageType]),
    CONSTRAINT [FK_UploadFilesDetail_UploadFile] FOREIGN KEY ([IdUploadFile]) REFERENCES [dbo].[UploadFiles] ([IdUploadFile])
);


GO
CREATE NONCLUSTERED INDEX [ix_UploadFilesDetail_IdUploadFile]
    ON [dbo].[UploadFilesDetail]([IdUploadFile] ASC);

