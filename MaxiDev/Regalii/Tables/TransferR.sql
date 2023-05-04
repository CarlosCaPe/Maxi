CREATE TABLE [Regalii].[TransferR] (
    [IdTransferR]                  BIGINT          IDENTITY (1, 1) NOT NULL,
    [IdAgent]                      INT             NOT NULL,
    [IdAgentPaymentSchema]         INT             NOT NULL,
    [EnterByIdUser]                INT             NOT NULL,
    [DateOfCreation]               DATETIME        NOT NULL,
    [EnterByIdUserCancel]          INT             NULL,
    [DateOfCancel]                 DATETIME        NULL,
    [IdStatus]                     INT             NOT NULL,
    [IdProductTransfer]            BIGINT          NOT NULL,
    [IdCustomer]                   INT             NULL,
    [CustomerName]                 NVARCHAR (3000) NULL,
    [CustomerFirstLastName]        NVARCHAR (3000) NULL,
    [CustomerSecondLastName]       NVARCHAR (3000) NULL,
    [CustomerCellPhoneNumber]      NVARCHAR (3000) NULL,
    [IdCarrier]                    INT             NULL,
    [TotalAmountToCorporate]       MONEY           NOT NULL,
    [Amount]                       MONEY           NOT NULL,
    [Commission]                   MONEY           NOT NULL,
    [AgentCommission]              MONEY           NOT NULL,
    [CorpCommission]               MONEY           NOT NULL,
    [Fee]                          MONEY           NOT NULL,
    [TransactionFee]               MONEY           NOT NULL,
    [ExRate]                       MONEY           NOT NULL,
    [IdBiller]                     INT             NOT NULL,
    [Account_Number]               NVARCHAR (3000) NULL,
    [IdCurrency]                   INT             NULL,
    [CurrencyName]                 NVARCHAR (500)  NULL,
    [AmountInMN]                   MONEY           NOT NULL,
    [Name_On_Account]              NVARCHAR (3000) NULL,
    [Pos_Number]                   NVARCHAR (3000) NULL,
    [JsonRequest]                  NVARCHAR (MAX)  NULL,
    [ProviderId]                   BIGINT          NULL,
    [Fx_Rate]                      MONEY           NULL,
    [Bill_Amount_Usd]              MONEY           NULL,
    [Bill_Amount_Chain_Currency]   MONEY           NULL,
    [Payment_Transaction_Fee]      MONEY           NULL,
    [Payment_Total_Usd]            MONEY           NULL,
    [Payment_Total_Chain_Currency] MONEY           NULL,
    [Chain_Earned]                 MONEY           NULL,
    [Chain_Paid]                   MONEY           NULL,
    [Starting_Balance]             MONEY           NULL,
    [Ending_Balance]               MONEY           NULL,
    [Discount]                     MONEY           NULL,
    [Sms_Text]                     NVARCHAR (MAX)  NULL,
    [ProviderDate]                 DATETIME        NULL,
    [JsonResponse]                 NVARCHAR (MAX)  NULL,
    [Name]                         VARCHAR (500)   NOT NULL,
    [Country]                      VARCHAR (500)   NOT NULL,
    [BillerType]                   VARCHAR (500)   NOT NULL,
    [CanCheckBalance]              BIT             NOT NULL,
    [SupportsPartialPayments]      BIT             NOT NULL,
    [RequiresNameOnAccount]        BIT             NOT NULL,
    [AvailableTopupAmounts]        VARCHAR (500)   NOT NULL,
    [HoursToFulfill]               VARCHAR (500)   NOT NULL,
    [LocalCurrency]                VARCHAR (500)   NOT NULL,
    [AccountNumberDigits]          VARCHAR (500)   NOT NULL,
    [Mask]                         VARCHAR (500)   NOT NULL,
    [BillType]                     VARCHAR (500)   NOT NULL,
    [IdCountry]                    INT             NULL,
    [TransactionExRate]            MONEY           DEFAULT ((0)) NOT NULL,
    [TopUpCommissionPercentage]    MONEY           NULL,
    [TopUpBonusAmountReceived]     MONEY           NULL,
    [IdSchema]                     INT             NULL,
    [IdOnWhoseBehalf]              INT             NULL,
    [DateOfCreationUTC]            DATETIME        DEFAULT (getutcdate()) NULL,
    CONSTRAINT [PK_TransferR] PRIMARY KEY CLUSTERED ([IdTransferR] ASC),
    CONSTRAINT [FK_TransferR_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_TransferR_AgentPaymentSchema] FOREIGN KEY ([IdAgentPaymentSchema]) REFERENCES [dbo].[AgentPaymentSchema] ([IdAgentPaymentSchema]),
    CONSTRAINT [FK_TransferR_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [FK_TransferR_UserCancel] FOREIGN KEY ([EnterByIdUserCancel]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [ix_TransferR_IdProductTransfer]
    ON [Regalii].[TransferR]([IdProductTransfer] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_TransferR_IdStatus_IdCustomer_DateOfCreation]
    ON [Regalii].[TransferR]([IdStatus] ASC, [IdCustomer] ASC, [DateOfCreation] ASC)
    INCLUDE([IdAgent], [EnterByIdUser], [IdProductTransfer], [CustomerFirstLastName], [Amount], [Fee], [Account_Number], [ProviderId], [Name], [BillerType]);


GO
CREATE NONCLUSTERED INDEX [IX_TransferR_IdCustomer]
    ON [Regalii].[TransferR]([IdCustomer] ASC);

