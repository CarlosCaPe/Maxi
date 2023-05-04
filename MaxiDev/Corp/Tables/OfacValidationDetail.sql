CREATE TABLE [Corp].[OfacValidationDetail] (
    [IdOfacValidationDetail]     INT            IDENTITY (1, 1) NOT NULL,
    [IdOfacValidation]           INT            NOT NULL,
    [Name]                       NVARCHAR (100) NULL,
    [DateOfBirth]                DATETIME       NULL,
    [CountryOfBirth]             NVARCHAR (50)  NULL,
    [IdOfacValidationEntityType] INT            NOT NULL,
    [HasMatch]                   BIT            NULL,
    [GeneralStatus]              NVARCHAR (50)  NULL,
    [Filter]                     NVARCHAR (50)  NULL,
    [IdUserApprove]              INT            NULL,
    [DateOfApproval]             DATETIME       NULL,
    [StatusChangeNote]           NVARCHAR (MAX) NULL,
    [IdUserCreation]             INT            NULL,
    [DateOfCreation]             DATETIME       NULL,
    [GeneralMessage]             NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_IdOfacValidationDetail] PRIMARY KEY CLUSTERED ([IdOfacValidationDetail] ASC),
    CONSTRAINT [FK_OfacValidation_Detail] FOREIGN KEY ([IdOfacValidation]) REFERENCES [Corp].[OfacValidation] ([IdOfacValidation]),
    CONSTRAINT [FK_OfacValidation_Type] FOREIGN KEY ([IdOfacValidationEntityType]) REFERENCES [Corp].[OfacValidationEntityType] ([IdOfacValidationEntityType])
);

