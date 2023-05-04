CREATE TABLE [TransFerTo].[ProductConfig] (
    [Country]              NVARCHAR (MAX) NULL,
    [CountryCode]          INT            NULL,
    [OperatorID]           INT            NULL,
    [Operator]             NVARCHAR (MAX) NULL,
    [DestinationCurrency]  NVARCHAR (MAX) NULL,
    [Product]              MONEY          NULL,
    [OriginatingCurrency]  NVARCHAR (MAX) NULL,
    [WholesalePrice]       MONEY          NULL,
    [SuggestedRetailPrice] MONEY          NULL,
    [RetailPrice]          MONEY          NULL,
    [Fee]                  MONEY          NULL,
    [Margin]               MONEY          NULL
);

