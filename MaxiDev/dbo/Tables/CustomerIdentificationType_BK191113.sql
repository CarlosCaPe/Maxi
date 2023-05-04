CREATE TABLE [dbo].[CustomerIdentificationType_BK191113] (
    [IdCustomerIdentificationType] INT            IDENTITY (1, 1) NOT NULL,
    [Name]                         NVARCHAR (MAX) NULL,
    [RequireSSN]                   BIT            NOT NULL,
    [StateRequired]                BIT            NOT NULL,
    [CountryRequired]              BIT            NOT NULL,
    [BTSIdentificationType]        VARCHAR (3)    NULL,
    [BTSIdentificationIssuer]      VARCHAR (3)    NULL,
    [NameEs]                       NVARCHAR (MAX) NULL,
    [ApprizaIdentificationType]    NVARCHAR (3)   NOT NULL
);

