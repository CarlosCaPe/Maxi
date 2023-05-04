CREATE TABLE [dbo].[CustomerIdentificationType] (
    [IdCustomerIdentificationType] INT            IDENTITY (1, 1) NOT NULL,
    [Name]                         NVARCHAR (MAX) NULL,
    [RequireSSN]                   BIT            NOT NULL,
    [StateRequired]                BIT            DEFAULT ((0)) NOT NULL,
    [CountryRequired]              BIT            DEFAULT ((0)) NOT NULL,
    [BTSIdentificationType]        VARCHAR (3)    NULL,
    [BTSIdentificationIssuer]      VARCHAR (3)    NULL,
    [NameEs]                       NVARCHAR (MAX) NULL,
    [ApprizaIdentificationType]    NVARCHAR (3)   DEFAULT ('') NOT NULL,
    [TransNetworkIDType]           VARCHAR (20)   NULL,
    [Active]                       BIT            DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_CustomerIdType] PRIMARY KEY CLUSTERED ([IdCustomerIdentificationType] ASC) WITH (FILLFACTOR = 90)
);

