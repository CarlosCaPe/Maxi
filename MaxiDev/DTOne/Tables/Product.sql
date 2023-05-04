﻿CREATE TABLE [DTOne].[Product] (
    [IdProduct]             INT           IDENTITY (1, 1) NOT NULL,
    [IdCountry]             INT           NOT NULL,
    [IdCarrier]             INT           NOT NULL,
    [IdDestinationCurrency] INT           NOT NULL,
    [IdOriginCurrency]      INT           NOT NULL,
    [Product]               MONEY         NOT NULL,
    [WholeSalePrice]        MONEY         NOT NULL,
    [SuggestedPrice]        MONEY         NOT NULL,
    [RetailPrice]           MONEY         NOT NULL,
    [Fee]                   MONEY         NOT NULL,
    [Margin]                MONEY         NOT NULL,
    [DateOfCreation]        DATETIME      NOT NULL,
    [DateOfLastChange]      DATETIME      NOT NULL,
    [EnterByIdUser]         INT           NOT NULL,
    [IdGenericStatus]       INT           NOT NULL,
    [IdCountryDTO]          NVARCHAR (50) NULL,
    [IdCarrierDTO]          INT           NULL,
    [IdProductDTO]          INT           NOT NULL,
    CONSTRAINT [PK_DTOProducts] PRIMARY KEY CLUSTERED ([IdProduct] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_DTOProduct_DTOCarrier] FOREIGN KEY ([IdCarrier]) REFERENCES [DTOne].[Carrier] ([IdCarrier]),
    CONSTRAINT [FK_DTOProduct_DTOCountry] FOREIGN KEY ([IdCountry]) REFERENCES [DTOne].[Country] ([IdCountry]),
    CONSTRAINT [FK_DTOProduct_DTOCurrency1] FOREIGN KEY ([IdOriginCurrency]) REFERENCES [DTOne].[Currency] ([IdCurrency]),
    CONSTRAINT [FK_DTOProduct_DTOCurrency2] FOREIGN KEY ([IdDestinationCurrency]) REFERENCES [DTOne].[Currency] ([IdCurrency]),
    CONSTRAINT [FK_DTOProduct_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_DTOProduct_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);
