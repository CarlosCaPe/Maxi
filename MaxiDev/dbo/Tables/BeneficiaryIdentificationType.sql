CREATE TABLE [dbo].[BeneficiaryIdentificationType] (
    [IdBeneficiaryIdentificationType] INT            IDENTITY (1, 1) NOT NULL,
    [IdCountry]                       INT            NOT NULL,
    [Name]                            NVARCHAR (MAX) NULL,
    [BTSIdentificationType]           VARCHAR (3)    NULL,
    [BTSIdentificationIssuer]         VARCHAR (3)    NULL,
    [NameEs]                          NVARCHAR (MAX) NULL,
    [NamePor]                         NVARCHAR (MAX) NULL,
    [ApprizaIdentificationType]       NVARCHAR (3)   DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_BeneficiaryIdType] PRIMARY KEY CLUSTERED ([IdBeneficiaryIdentificationType] ASC) WITH (FILLFACTOR = 90)
);

