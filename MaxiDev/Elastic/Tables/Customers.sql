CREATE TABLE [Elastic].[Customers] (
    [IdCustomer]        INT           NULL,
    [Name]              VARCHAR (MAX) NULL,
    [FirstLastName]     VARCHAR (MAX) NULL,
    [SecondLastName]    VARCHAR (MAX) NULL,
    [City]              VARCHAR (MAX) NULL,
    [State]             VARCHAR (MAX) NULL,
    [Country]           VARCHAR (MAX) NULL,
    [Address]           VARCHAR (MAX) NULL,
    [IdAgent]           INT           NULL,
    [CardNumber]        VARCHAR (MAX) NULL,
    [CelullarNumber]    VARCHAR (MAX) NULL,
    [CelullarToShow]    VARCHAR (MAX) NULL,
    [PhoneNumber]       VARCHAR (MAX) NULL,
    [PhoneToShow]       VARCHAR (MAX) NULL,
    [SearchString]      VARCHAR (MAX) NULL,
    [idElasticCustomer] VARCHAR (MAX) NULL,
    [Status]            INT           NULL,
    [lastUpdate]        DATETIME      NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_Customers_IdCustomer]
    ON [Elastic].[Customers]([IdCustomer] ASC);

