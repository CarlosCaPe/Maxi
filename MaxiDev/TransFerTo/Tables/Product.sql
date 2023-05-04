CREATE TABLE [TransFerTo].[Product] (
    [IdProduct]             INT      IDENTITY (1, 1) NOT NULL,
    [IdCountry]             INT      NOT NULL,
    [IdCarrier]             INT      NOT NULL,
    [IdDestinationCurrency] INT      NOT NULL,
    [IdOriginCurrency]      INT      NOT NULL,
    [Product]               MONEY    NOT NULL,
    [WholeSalePrice]        MONEY    NOT NULL,
    [SuggestedPrice]        MONEY    NOT NULL,
    [RetailPrice]           MONEY    NOT NULL,
    [Fee]                   MONEY    NOT NULL,
    [Margin]                MONEY    NOT NULL,
    [DateOfCreation]        DATETIME NOT NULL,
    [DateOfLastChange]      DATETIME NOT NULL,
    [EnterByIdUser]         INT      NOT NULL,
    [IdGenericStatus]       INT      NOT NULL,
    [IdCountryTTo]          INT      NULL,
    [IdCarrierTTo]          INT      NULL,
    CONSTRAINT [PK_TransferTToProducts] PRIMARY KEY CLUSTERED ([IdProduct] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_TToProduct_TToCarrier] FOREIGN KEY ([IdCarrier]) REFERENCES [TransFerTo].[Carrier] ([IdCarrier]),
    CONSTRAINT [FK_TToProduct_TToCountry] FOREIGN KEY ([IdCountry]) REFERENCES [TransFerTo].[Country] ([IdCountry]),
    CONSTRAINT [FK_TToProduct_TToCurrency1] FOREIGN KEY ([IdOriginCurrency]) REFERENCES [TransFerTo].[Currency] ([IdCurrency]),
    CONSTRAINT [FK_TToProduct_TToCurrency2] FOREIGN KEY ([IdDestinationCurrency]) REFERENCES [TransFerTo].[Currency] ([IdCurrency]),
    CONSTRAINT [FK_TToProduct_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [FK_TTProduct_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus])
);


GO
CREATE NONCLUSTERED INDEX [IX_Product_IdGenericStatus]
    ON [TransFerTo].[Product]([IdGenericStatus] ASC)
    INCLUDE([IdProduct], [IdCountry], [IdCarrier], [RetailPrice], [Margin]);


GO
CREATE NONCLUSTERED INDEX [IX_Product_IdCarrier_IdGenericStatus]
    ON [TransFerTo].[Product]([IdCarrier] ASC, [IdGenericStatus] ASC);

