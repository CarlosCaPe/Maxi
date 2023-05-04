CREATE TABLE [dbo].[CarrierPureMinutesTopUp] (
    [IdCarrierPureMinutesTopUp] INT            NOT NULL,
    [CarrierName]               NVARCHAR (MAX) NOT NULL,
    [IdCountryPureMinutesTopUp] INT            NOT NULL,
    CONSTRAINT [PK_CarrierPureMinutesTopUp] PRIMARY KEY CLUSTERED ([IdCarrierPureMinutesTopUp] ASC) WITH (FILLFACTOR = 90)
);

