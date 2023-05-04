CREATE TABLE [dbo].[UploadFiles] (
    [IdUploadFile]              INT            IDENTITY (1, 1) NOT NULL,
    [IdReference]               INT            NOT NULL,
    [IdDocumentType]            INT            NOT NULL,
    [FileName]                  NVARCHAR (MAX) NOT NULL,
    [FileGuid]                  NVARCHAR (MAX) NOT NULL,
    [Extension]                 NVARCHAR (MAX) NULL,
    [IdStatus]                  INT            NOT NULL,
    [IdUser]                    INT            NOT NULL,
    [LastChange_LastUserChange] NVARCHAR (MAX) NULL,
    [LastChange_LastDateChange] DATETIME       NOT NULL,
    [LastChange_LastIpChange]   NVARCHAR (MAX) NULL,
    [LastChange_LastNoteChange] NVARCHAR (MAX) NULL,
    [ExpirationDate]            DATE           NULL,
    [CreationDate]              DATETIME       CONSTRAINT [DF_UploadFiles_CreationDate] DEFAULT (getdate()) NOT NULL,
    [IsPhysicalDeleted]         BIT            NULL,
    [DateOfBirth]               DATETIME       NULL,
    [IdLanguage]                INT            NULL,
    CONSTRAINT [PK_UploadFiles] PRIMARY KEY CLUSTERED ([IdUploadFile] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_UploadFiles_DocumentTypes1] FOREIGN KEY ([IdDocumentType]) REFERENCES [dbo].[DocumentTypes] ([IdDocumentType]),
    CONSTRAINT [FK_UploadFiles_Lenguage] FOREIGN KEY ([IdLanguage]) REFERENCES [dbo].[Lenguage] ([IdLenguage]),
    CONSTRAINT [FK_UploadFiles_Users1] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IX_UploadFiles_IdDocumentType_IdStatus_IdReference]
    ON [dbo].[UploadFiles]([IdDocumentType] ASC, [IdStatus] ASC, [IdReference] ASC)
    INCLUDE([IdUploadFile], [FileName]);


GO
CREATE NONCLUSTERED INDEX [ix_UploadFiles_IdReference_IdDocumentType]
    ON [dbo].[UploadFiles]([IdReference] ASC, [IdDocumentType] ASC);

