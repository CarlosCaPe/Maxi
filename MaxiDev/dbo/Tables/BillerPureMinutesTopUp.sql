CREATE TABLE [dbo].[BillerPureMinutesTopUp] (
    [IdBiller]                  INT            IDENTITY (1, 1) NOT NULL,
    [IdBillerPureMinutesTopUp]  INT            NOT NULL,
    [DigitMax]                  INT            NULL,
    [DigitMin]                  INT            NULL,
    [ReceiverAmount]            NVARCHAR (MAX) NULL,
    [RechargeAmount]            NVARCHAR (MAX) NULL,
    [ReceiverCurrency]          NVARCHAR (MAX) NULL,
    [RechargeCurrency]          NVARCHAR (MAX) NULL,
    [IdCarrierPureMinutesTopUp] INT            NOT NULL,
    [IdCountryPureMinutesTopUp] INT            NOT NULL,
    [RetailerCommission]        FLOAT (53)     NULL,
    CONSTRAINT [PK__BillerPureMinutesTopUp] PRIMARY KEY CLUSTERED ([IdBiller] ASC) WITH (FILLFACTOR = 90)
);

