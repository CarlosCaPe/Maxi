CREATE TABLE [dbo].[BeneficiaryMirror] (
    [IdBeneficiaryMirror]             INT            IDENTITY (1, 1) NOT NULL,
    [IdBeneficiary]                   INT            NULL,
    [Name]                            NVARCHAR (MAX) NULL,
    [FirstLastName]                   NVARCHAR (MAX) NULL,
    [SecondLastName]                  NVARCHAR (MAX) NOT NULL,
    [Address]                         NVARCHAR (MAX) NULL,
    [City]                            NVARCHAR (MAX) NULL,
    [State]                           NVARCHAR (MAX) NULL,
    [Country]                         NVARCHAR (MAX) NULL,
    [Zipcode]                         NVARCHAR (MAX) NULL,
    [PhoneNumber]                     NVARCHAR (MAX) NULL,
    [CelullarNumber]                  NVARCHAR (MAX) NULL,
    [SSnumber]                        NVARCHAR (MAX) NULL,
    [BornDate]                        DATETIME       NULL,
    [Occupation]                      NVARCHAR (MAX) NULL,
    [Note]                            NVARCHAR (MAX) NULL,
    [IdGenericStatus]                 INT            NULL,
    [DateOfLastChange]                DATETIME       NULL,
    [EnterByIdUser]                   INT            NULL,
    [IdCustomer]                      INT            NULL,
    [FullName]                        NVARCHAR (120) NULL,
    [IdBeneficiaryIdentificationType] INT            NULL,
    [IdentificationNumber]            NVARCHAR (MAX) NULL,
    [IdCountryOfBirth]                INT            NULL,
    [IdTransfer]                      INT            NOT NULL,
    [ConfirmationCode]                VARCHAR (250)  NULL,
    CONSTRAINT [PK_IBeneficiaryMirror] PRIMARY KEY CLUSTERED ([IdBeneficiaryMirror] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_BeneficiaryMirror_IdTransfer]
    ON [dbo].[BeneficiaryMirror]([IdTransfer] ASC);

