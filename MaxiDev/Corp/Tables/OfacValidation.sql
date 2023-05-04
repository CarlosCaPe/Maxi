CREATE TABLE [Corp].[OfacValidation] (
    [IdOfacValidation] INT            IDENTITY (1, 1) NOT NULL,
    [FileName]         NVARCHAR (100) NULL,
    [DateOfCreation]   DATETIME       NOT NULL,
    [IdUser]           INT            NOT NULL,
    CONSTRAINT [PK_IdOfacValidation] PRIMARY KEY CLUSTERED ([IdOfacValidation] ASC)
);

