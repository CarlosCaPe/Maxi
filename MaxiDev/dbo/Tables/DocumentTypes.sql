CREATE TABLE [dbo].[DocumentTypes] (
    [IdDocumentType]      INT            IDENTITY (1, 1) NOT NULL,
    [Name]                NVARCHAR (MAX) NOT NULL,
    [IdType]              INT            NULL,
    [RelativePath]        NVARCHAR (MAX) NULL,
    [GenerateBySystem]    BIT            NULL,
    [IdDocumentTypeDad]   INT            NULL,
    [DateOfBirthRequired] BIT            NULL,
    CONSTRAINT [PK_DocumentTypes] PRIMARY KEY CLUSTERED ([IdDocumentType] ASC) WITH (FILLFACTOR = 90)
);

