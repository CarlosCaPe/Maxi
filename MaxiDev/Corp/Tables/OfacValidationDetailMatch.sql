CREATE TABLE [Corp].[OfacValidationDetailMatch] (
    [IdOfacValidationDetailMatch] INT            IDENTITY (1, 1) NOT NULL,
    [IdOfacValidationDetail]      INT            NOT NULL,
    [Score]                       DECIMAL (5, 2) NULL,
    [Status]                      NVARCHAR (50)  NULL,
    [EntNum]                      INT            NULL,
    [AltNum]                      INT            NULL,
    [Name]                        NVARCHAR (100) NULL,
    [LastName]                    NVARCHAR (100) NULL,
    [NameComplete]                NVARCHAR (100) NULL,
    [Remarks]                     NVARCHAR (MAX) NULL,
    [IdOfacValidationEntityType]  INT            NOT NULL,
    [Address]                     NVARCHAR (150) NULL,
    [CityName]                    NVARCHAR (150) NULL,
    [Country]                     NVARCHAR (150) NULL,
    [AddRemarks]                  NVARCHAR (150) NULL,
    [IdUserCreation]              INT            NOT NULL,
    [DateOfCreation]              DATETIME       NULL,
    CONSTRAINT [PK_IdOfacValidationMatch] PRIMARY KEY CLUSTERED ([IdOfacValidationDetailMatch] ASC),
    CONSTRAINT [FK_OfacValidationDetail_Match] FOREIGN KEY ([IdOfacValidationDetail]) REFERENCES [Corp].[OfacValidationDetail] ([IdOfacValidationDetail]),
    CONSTRAINT [FK_OfacValidationMatch_Type] FOREIGN KEY ([IdOfacValidationEntityType]) REFERENCES [Corp].[OfacValidationEntityType] ([IdOfacValidationEntityType])
);

