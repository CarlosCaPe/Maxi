CREATE TABLE [Corp].[OfacValidationDetailMatchAka] (
    [IdOfacValidationDetailMatchAka] INT            IDENTITY (1, 1) NOT NULL,
    [IdOfacValidationDetailMatch]    INT            NOT NULL,
    [Score]                          DECIMAL (5, 2) NULL,
    [Status]                         NVARCHAR (50)  NULL,
    [EntNum]                         INT            NULL,
    [AltNum]                         INT            NULL,
    [Name]                           NVARCHAR (100) NULL,
    [LastName]                       NVARCHAR (100) NULL,
    [NameComplete]                   NVARCHAR (100) NULL,
    [Remarks]                        NVARCHAR (MAX) NULL,
    [Type]                           NVARCHAR (50)  NULL,
    [Address]                        NVARCHAR (150) NULL,
    [CityName]                       NVARCHAR (150) NULL,
    [Country]                        NVARCHAR (150) NULL,
    [AddRemarks]                     NVARCHAR (150) NULL,
    [IdUserCreation]                 INT            NOT NULL,
    [DateOfCreation]                 DATETIME       NULL,
    CONSTRAINT [PK_IdOfacValidationMatchAka] PRIMARY KEY CLUSTERED ([IdOfacValidationDetailMatchAka] ASC),
    CONSTRAINT [FK_OfacValidationDetailMatch_Aka] FOREIGN KEY ([IdOfacValidationDetailMatch]) REFERENCES [Corp].[OfacValidationDetailMatch] ([IdOfacValidationDetailMatch])
);

