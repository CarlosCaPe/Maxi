CREATE TABLE [Operation].[Carrier] (
    [IdCarrier]       INT            IDENTITY (1, 1) NOT NULL,
    [IdGenericStatus] INT            NOT NULL,
    [EnteredByIdUser] INT            NOT NULL,
    [Provider]        INT            NOT NULL,
    [CarrierName]     NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_Carrier] PRIMARY KEY CLUSTERED ([IdCarrier] ASC)
);

