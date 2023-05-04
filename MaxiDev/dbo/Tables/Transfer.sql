CREATE TABLE [dbo].[Transfer] (
    [IdTransfer]                           INT            IDENTITY (1, 1) NOT NULL,
    [IdCustomer]                           INT            NOT NULL,
    [IdBeneficiary]                        INT            NOT NULL,
    [IdPaymentType]                        INT            NOT NULL,
    [IdBranch]                             INT            NULL,
    [IdPayer]                              INT            NOT NULL,
    [IdGateway]                            INT            NULL,
    [GatewayBranchCode]                    NVARCHAR (MAX) NOT NULL,
    [IdAgentPaymentSchema]                 INT            NOT NULL,
    [IdAgent]                              INT            NOT NULL,
    [IdAgentSchema]                        INT            NULL,
    [IdCountryCurrency]                    INT            NOT NULL,
    [IdStatus]                             INT            NOT NULL,
    [ClaimCode]                            NVARCHAR (50)  NOT NULL,
    [ConfirmationCode]                     NVARCHAR (50)  NOT NULL,
    [AmountInDollars]                      MONEY          NOT NULL,
    [Fee]                                  MONEY          NOT NULL,
    [AgentCommission]                      MONEY          NOT NULL,
    [CorporateCommission]                  MONEY          NOT NULL,
    [DateOfTransfer]                       DATETIME       NOT NULL,
    [ExRate]                               MONEY          NOT NULL,
    [ReferenceExRate]                      MONEY          NOT NULL,
    [AmountInMN]                           MONEY          NOT NULL,
    [Folio]                                INT            NOT NULL,
    [DepositAccountNumber]                 NVARCHAR (MAX) NOT NULL,
    [DateOfLastChange]                     DATETIME       NOT NULL,
    [EnterByIdUser]                        INT            NOT NULL,
    [TotalAmountToCorporate]               MONEY          NOT NULL,
    [BeneficiaryName]                      NVARCHAR (MAX) NOT NULL,
    [BeneficiaryFirstLastName]             NVARCHAR (MAX) NOT NULL,
    [BeneficiarySecondLastName]            NVARCHAR (MAX) NOT NULL,
    [BeneficiaryAddress]                   NVARCHAR (MAX) NOT NULL,
    [BeneficiaryCity]                      NVARCHAR (MAX) NOT NULL,
    [BeneficiaryState]                     NVARCHAR (MAX) NOT NULL,
    [BeneficiaryCountry]                   NVARCHAR (MAX) NOT NULL,
    [BeneficiaryZipcode]                   NVARCHAR (MAX) NOT NULL,
    [BeneficiaryPhoneNumber]               NVARCHAR (MAX) NOT NULL,
    [BeneficiaryCelularNumber]             NVARCHAR (MAX) NOT NULL,
    [BeneficiarySSNumber]                  NVARCHAR (MAX) NULL,
    [BeneficiaryBornDate]                  DATETIME       NULL,
    [BeneficiaryOccupation]                NVARCHAR (MAX) NULL,
    [BeneficiaryNote]                      NVARCHAR (MAX) NOT NULL,
    [CustomerName]                         NVARCHAR (MAX) NOT NULL,
    [CustomerIdAgentCreatedBy]             INT            NOT NULL,
    [CustomerIdCustomerIdentificationType] INT            NULL,
    [CustomerFirstLastName]                NVARCHAR (MAX) NOT NULL,
    [CustomerSecondLastName]               NVARCHAR (MAX) NOT NULL,
    [CustomerAddress]                      NVARCHAR (MAX) NOT NULL,
    [CustomerCity]                         NVARCHAR (MAX) NOT NULL,
    [CustomerState]                        NVARCHAR (MAX) NOT NULL,
    [CustomerCountry]                      NVARCHAR (MAX) NOT NULL,
    [CustomerZipcode]                      NVARCHAR (MAX) NOT NULL,
    [CustomerPhoneNumber]                  NVARCHAR (MAX) NOT NULL,
    [CustomerCelullarNumber]               NVARCHAR (MAX) NOT NULL,
    [CustomerSSNumber]                     NVARCHAR (MAX) NOT NULL,
    [CustomerBornDate]                     DATETIME       NULL,
    [CustomerOccupation]                   NVARCHAR (MAX) NOT NULL,
    [CustomerIdentificationNumber]         NVARCHAR (MAX) NOT NULL,
    [CustomerExpirationIdentification]     DATETIME       NULL,
    [IdOnWhoseBehalf]                      INT            NULL,
    [Purpose]                              NVARCHAR (200) NOT NULL,
    [Relationship]                         NVARCHAR (200) NOT NULL,
    [MoneySource]                          NVARCHAR (200) NOT NULL,
    [AgentCommissionExtra]                 MONEY          NOT NULL,
    [AgentCommissionOriginal]              MONEY          NOT NULL,
    [ModifierCommissionSlider]             MONEY          NOT NULL,
    [ModifierExchangeRateSlider]           MONEY          NOT NULL,
    [CustomerIdCarrier]                    INT            NULL,
    [IdSeller]                             INT            NOT NULL,
    [ReviewDenyList]                       BIT            NULL,
    [ReviewOfac]                           BIT            NULL,
    [ReviewKYC]                            BIT            NULL,
    [ReviewRejected]                       BIT            NULL,
    [ReviewGateway]                        BIT            NULL,
    [ReviewReturned]                       BIT            NULL,
    [OriginExRate]                         MONEY          NOT NULL,
    [OriginAmountInMN]                     MONEY          NOT NULL,
    [DateStatusChange]                     DATETIME       NULL,
    [NoteAdditional]                       NVARCHAR (MAX) NULL,
    [CustomerIdentificationIdCountry]      INT            NULL,
    [CustomerIdentificationIdState]        INT            NULL,
    [IdReasonForCancel]                    INT            NULL,
    [IdBeneficiaryIdentificationType]      INT            NULL,
    [BeneficiaryIdentificationNumber]      NVARCHAR (MAX) NULL,
    [AgentNotificationSent]                BIT            DEFAULT ((0)) NOT NULL,
    [EmailByJobSent]                       BIT            DEFAULT ((0)) NOT NULL,
    [FromStandByToKYC]                     BIT            DEFAULT ((0)) NULL,
    [CustomerIdCountryOfBirth]             INT            NULL,
    [BeneficiaryIdCountryOfBirth]          INT            NULL,
    [AccountTypeId]                        INT            NULL,
    [ReviewId]                             BIT            NULL,
    [CustomerOccupationDetail]             NVARCHAR (MAX) DEFAULT (NULL) NULL,
    [TransferIdCity]                       INT            DEFAULT (NULL) NULL,
    [BeneficiaryIdCarrier]                 INT            DEFAULT (NULL) NULL,
    [FeeSecondary]                         MONEY          NULL,
    [NumModify]                            INT            DEFAULT ((0)) NULL,
    [CustomerIdOccupation]                 INT            NULL,
    [CustomerIdSubOccupation]              INT            NULL,
    [CustomerSubOccupationOther]           VARCHAR (50)   NULL,
    [BranchCodePontual]                    VARCHAR (10)   NULL,
    [IdTransferResend]                     INT            NULL,
    [StateTax]                             MONEY          NULL,
    [IdPaymentMethod]                      INT            CONSTRAINT [DF_Transfer_PaymentMethod] DEFAULT ((1)) NOT NULL,
    [Discount]                             MONEY          CONSTRAINT [DF_Transfer_Discount] DEFAULT ((0)) NOT NULL,
    [DateOfTransferUTC]                    DATETIME       NULL,
    [OperationFee]                         MONEY          CONSTRAINT [DF_Transfer_OperationFee] DEFAULT ((0)) NOT NULL,
    [IsValidCustomerPhoneNumber]           BIT            NULL,
    [IdDialingCodePhoneNumber]             INT            NULL,
    [IdDialingCodeBeneficiaryPhoneNumber]  INT            NULL,
    [IsRequiredCustomerPhoneNumber]        BIT            NULL,
    [IsRefunded]                           BIT            NULL,
    CONSTRAINT [PK_Transfer] PRIMARY KEY CLUSTERED ([IdTransfer] ASC) WITH (FILLFACTOR = 90),
    FOREIGN KEY ([AccountTypeId]) REFERENCES [dbo].[AccountType] ([AccountTypeId]),
    FOREIGN KEY ([BeneficiaryIdCountryOfBirth]) REFERENCES [dbo].[CountryBirth] ([IdCountryBirth]),
    FOREIGN KEY ([CustomerIdCountryOfBirth]) REFERENCES [dbo].[CountryBirth] ([IdCountryBirth]),
    FOREIGN KEY ([IdDialingCodePhoneNumber]) REFERENCES [dbo].[DialingCodePhoneNumber] ([IdDialingCodePhoneNumber]),
    CONSTRAINT [FK_Transfer_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_Transfer_Beneficiary] FOREIGN KEY ([IdBeneficiary]) REFERENCES [dbo].[Beneficiary] ([IdBeneficiary]),
    CONSTRAINT [FK_Transfer_Beneficiary_DialingCodePhoneNumber] FOREIGN KEY ([IdDialingCodeBeneficiaryPhoneNumber]) REFERENCES [dbo].[DialingCodePhoneNumber] ([IdDialingCodePhoneNumber]),
    CONSTRAINT [FK_Transfer_Branch] FOREIGN KEY ([IdBranch]) REFERENCES [dbo].[Branch] ([IdBranch]),
    CONSTRAINT [FK_Transfer_City] FOREIGN KEY ([TransferIdCity]) REFERENCES [dbo].[City] ([IdCity]),
    CONSTRAINT [FK_Transfer_Country] FOREIGN KEY ([CustomerIdentificationIdCountry]) REFERENCES [dbo].[Country] ([IdCountry]),
    CONSTRAINT [FK_Transfer_CountryCurrency] FOREIGN KEY ([IdCountryCurrency]) REFERENCES [dbo].[CountryCurrency] ([IdCountryCurrency]),
    CONSTRAINT [FK_Transfer_Customer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_Transfer_Gateway] FOREIGN KEY ([IdGateway]) REFERENCES [dbo].[Gateway] ([IdGateway]),
    CONSTRAINT [FK_Transfer_IDType] FOREIGN KEY ([IdBeneficiaryIdentificationType]) REFERENCES [dbo].[BeneficiaryIdentificationType] ([IdBeneficiaryIdentificationType]),
    CONSTRAINT [FK_Transfer_OnWhoseBehalf] FOREIGN KEY ([IdOnWhoseBehalf]) REFERENCES [dbo].[OnWhoseBehalf] ([IdOnWhoseBehalf]),
    CONSTRAINT [FK_Transfer_Payer] FOREIGN KEY ([IdPayer]) REFERENCES [dbo].[Payer] ([IdPayer]),
    CONSTRAINT [FK_Transfer_PaymentMethod] FOREIGN KEY ([IdPaymentMethod]) REFERENCES [dbo].[PaymentMethod] ([IdPaymentMethod]),
    CONSTRAINT [FK_Transfer_PaymentType] FOREIGN KEY ([IdPaymentType]) REFERENCES [dbo].[PaymentType] ([IdPaymentType]),
    CONSTRAINT [FK_transfer_ReasonForCancel] FOREIGN KEY ([IdReasonForCancel]) REFERENCES [dbo].[ReasonForCancel] ([IdReasonForCancel]),
    CONSTRAINT [FK_Transfer_State] FOREIGN KEY ([CustomerIdentificationIdState]) REFERENCES [dbo].[State] ([IdState]),
    CONSTRAINT [FK_Transfer_Status] FOREIGN KEY ([IdStatus]) REFERENCES [dbo].[Status] ([IdStatus])
);


GO
CREATE NONCLUSTERED INDEX [IX_Transfer_EnterByIdUser]
    ON [dbo].[Transfer]([EnterByIdUser] ASC)
    INCLUDE([IdTransfer], [IdCustomer], [IdBeneficiary], [AmountInDollars], [DateOfTransfer]);


GO
CREATE NONCLUSTERED INDEX [ixClaimCode]
    ON [dbo].[Transfer]([ClaimCode] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [ixCustomer]
    ON [dbo].[Transfer]([IdCustomer] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Transfer_IdCountryCurrency_DateOfTransfer]
    ON [dbo].[Transfer]([IdCountryCurrency] ASC, [DateOfTransfer] ASC)
    INCLUDE([IdPaymentType], [IdPayer], [IdGateway], [IdAgent], [AmountInDollars], [Fee], [AgentCommission], [ExRate], [ReferenceExRate]);


GO
CREATE NONCLUSTERED INDEX [IX_Transfer_IdGateway_IdPayer_IdStatus_ClaimCode_DateStatusChange]
    ON [dbo].[Transfer]([IdGateway] ASC, [IdStatus] ASC, [IdPayer] ASC, [ClaimCode] ASC, [DateStatusChange] ASC)
    INCLUDE([IdTransfer], [DateOfTransfer], [IdPaymentType]);


GO
CREATE NONCLUSTERED INDEX [IX_Transfer_DateOfTransfer_II]
    ON [dbo].[Transfer]([DateOfTransfer] ASC)
    INCLUDE([IdTransfer], [CustomerFirstLastName]);


GO
CREATE NONCLUSTERED INDEX [IX_Transfer_Folio_DateOfTransfer]
    ON [dbo].[Transfer]([Folio] ASC, [DateOfTransfer] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Transfer_IdAgent_Folio_DateOfTransfer_EnterByIdUser]
    ON [dbo].[Transfer]([IdAgent] ASC, [IdStatus] ASC, [Folio] ASC, [DateOfTransfer] ASC, [EnterByIdUser] ASC)
    INCLUDE([IdTransfer], [ClaimCode], [AmountInDollars], [AmountInMN], [ExRate], [Fee]);


GO
CREATE NONCLUSTERED INDEX [IX_TransferIdBeneficiaryIdStatusDateOfTransfer]
    ON [dbo].[Transfer]([IdBeneficiary] ASC, [IdStatus] ASC, [DateOfTransfer] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Transfer_IdStatus_DateStatusChange]
    ON [dbo].[Transfer]([IdStatus] ASC, [DateStatusChange] ASC)
    INCLUDE([IdPaymentType], [IdPayer], [IdGateway], [IdAgentPaymentSchema], [IdAgent], [IdCountryCurrency], [AmountInDollars], [ExRate], [ReferenceExRate]);


GO
CREATE NONCLUSTERED INDEX [IX_Transfer_IdPayer_IdGateway_DateOfTransfer]
    ON [dbo].[Transfer]([IdPayer] ASC, [IdGateway] ASC, [DateOfTransfer] ASC)
    INCLUDE([IdTransfer]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad a depositar por transaccion al corporativo. ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Transfer', @level2type = N'COLUMN', @level2name = N'TotalAmountToCorporate';

