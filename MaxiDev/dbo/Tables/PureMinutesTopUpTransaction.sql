CREATE TABLE [dbo].[PureMinutesTopUpTransaction] (
    [IdPureMinutesTopUp]      INT            IDENTITY (1, 1) NOT NULL,
    [IdUser]                  INT            NOT NULL,
    [IdAgent]                 INT            NOT NULL,
    [DateOfTransaction]       DATETIME       NOT NULL,
    [DateOfLastChange]        DATETIME       NOT NULL,
    [BillerID]                INT            NOT NULL,
    [CarrierID]               INT            NOT NULL,
    [CountryID]               INT            NOT NULL,
    [TopUpNumber]             VARCHAR (200)  NULL,
    [BuyerPhonenumber]        NVARCHAR (MAX) NOT NULL,
    [TopUpAmount]             MONEY          NOT NULL,
    [PureMinutesTopUpTransID] NVARCHAR (MAX) NULL,
    [EntryTimeStamp]          NVARCHAR (MAX) NULL,
    [ReturnCode]              NVARCHAR (MAX) NULL,
    [ReasonCode]              NVARCHAR (MAX) NULL,
    [ReceiverCurrency]        NVARCHAR (MAX) NULL,
    [RechargeCurrency]        NVARCHAR (MAX) NULL,
    [ReceiverAmount]          NVARCHAR (MAX) NULL,
    [RechargeAmount]          NVARCHAR (MAX) NULL,
    [Fee]                     MONEY          NULL,
    [AgentCommission]         MONEY          NOT NULL,
    [CorpCommission]          MONEY          NOT NULL,
    [Status]                  INT            NOT NULL,
    [LastReturnCode]          NVARCHAR (MAX) NULL,
    [Request]                 NVARCHAR (MAX) NULL,
    [Response]                NVARCHAR (MAX) NULL,
    [ErrorMsg]                NVARCHAR (MAX) NULL,
    [ResponseMsg]             NVARCHAR (MAX) NULL,
    [IdBiller]                INT            NULL,
    [IdProductTransfer]       BIGINT         NULL,
    CONSTRAINT [PK__PureMinutesTopUpTransaction] PRIMARY KEY CLUSTERED ([IdPureMinutesTopUp] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_PhonePureMinutesTopUpTransaction]
    ON [dbo].[PureMinutesTopUpTransaction]([TopUpNumber] ASC);

