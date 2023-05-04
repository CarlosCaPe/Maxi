CREATE TABLE [dbo].[ReportPendingTransferAccepted] (
    [GatewayName]      NVARCHAR (MAX) NULL,
    [PayerName]        NVARCHAR (MAX) NULL,
    [DateOfTransfer]   DATETIME       NULL,
    [DateStatusChange] DATETIME       NULL,
    [claimcode]        NVARCHAR (MAX) NULL,
    [AmountInDollars]  MONEY          NULL,
    [AmountInMN]       MONEY          NULL,
    [StatusName]       NVARCHAR (MAX) NULL,
    [CurrencyName]     NVARCHAR (MAX) NULL,
    [CountryName]      NVARCHAR (MAX) NULL,
    [insertdate]       DATETIME       NULL
);

