﻿CREATE TABLE [dbo].[OnWhoseBehalf] (
    [IdOnWhoseBehalf]              INT            IDENTITY (1, 1) NOT NULL,
    [IdAgentCreatedBy]             INT            NOT NULL,
    [IdGenericStatus]              INT            NOT NULL,
    [Name]                         NVARCHAR (MAX) NOT NULL,
    [FirstLastName]                NVARCHAR (MAX) NOT NULL,
    [SecondLastName]               NVARCHAR (MAX) NOT NULL,
    [Address]                      NVARCHAR (MAX) NOT NULL,
    [City]                         NVARCHAR (MAX) NOT NULL,
    [State]                        NVARCHAR (MAX) NOT NULL,
    [Country]                      NVARCHAR (MAX) NOT NULL,
    [Zipcode]                      NVARCHAR (MAX) NOT NULL,
    [PhoneNumber]                  NVARCHAR (MAX) NOT NULL,
    [CelullarNumber]               NVARCHAR (MAX) NOT NULL,
    [SSNumber]                     NVARCHAR (MAX) NOT NULL,
    [BornDate]                     DATETIME       NULL,
    [Occupation]                   NVARCHAR (MAX) NOT NULL,
    [IdentificationNumber]         NVARCHAR (MAX) NOT NULL,
    [PhysicalIdCopy]               INT            NOT NULL,
    [IdCustomerIdentificationType] INT            NULL,
    [ExpirationIdentification]     DATETIME       NULL,
    [Purpose]                      NVARCHAR (200) NOT NULL,
    [Relationship]                 NVARCHAR (200) NOT NULL,
    [MoneySource]                  NVARCHAR (200) NOT NULL,
    [DateOfLastChange]             DATETIME       NOT NULL,
    [EnterByIdUser]                INT            NOT NULL,
    [IdOccupation]                 INT            NULL,
    [IdSubcategoryOccupation]      INT            NULL,
    [SubcategoryOccupationOther]   VARCHAR (50)   NULL,
    CONSTRAINT [PK_OnWhoseBehalf] PRIMARY KEY CLUSTERED ([IdOnWhoseBehalf] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_OnWhoseBehalf_Agent] FOREIGN KEY ([IdAgentCreatedBy]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_OnWhoseBehalf_CustomerIdentificationType] FOREIGN KEY ([IdCustomerIdentificationType]) REFERENCES [dbo].[CustomerIdentificationType] ([IdCustomerIdentificationType]),
    CONSTRAINT [FK_OnWhoseBehalf_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus])
);

