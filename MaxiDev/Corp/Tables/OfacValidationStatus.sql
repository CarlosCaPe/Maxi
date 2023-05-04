CREATE TABLE [Corp].[OfacValidationStatus] (
    [IdOfacValidationStatus] INT           IDENTITY (1, 1) NOT NULL,
    [Code]                   NVARCHAR (50) NOT NULL,
    [Name]                   NVARCHAR (50) NULL,
    CONSTRAINT [PK_OfacValidationStatus] PRIMARY KEY CLUSTERED ([IdOfacValidationStatus] ASC)
);

