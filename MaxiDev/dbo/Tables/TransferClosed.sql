CREATE TABLE [dbo].[TransferClosed] (
    [IdTransferClosed]                     INT            NOT NULL,
    [IdCustomer]                           INT            NOT NULL,
    [IdBeneficiary]                        INT            NOT NULL,
    [IdPaymentType]                        INT            NOT NULL,
    [PaymentTypeName]                      NVARCHAR (MAX) NOT NULL,
    [IdBranch]                             INT            NULL,
    [BranchName]                           NVARCHAR (MAX) NULL,
    [IdPayer]                              INT            NOT NULL,
    [PayerName]                            NVARCHAR (MAX) NOT NULL,
    [IdGateway]                            INT            NULL,
    [GatewayName]                          NVARCHAR (MAX) NULL,
    [GatewayBranchCode]                    NVARCHAR (MAX) NULL,
    [IdAgentPaymentSchema]                 INT            NOT NULL,
    [AgentPaymentSchema]                   NVARCHAR (MAX) NOT NULL,
    [IdAgent]                              INT            NOT NULL,
    [AgentName]                            NVARCHAR (MAX) NOT NULL,
    [IdAgentSchema]                        INT            NULL,
    [SchemaName]                           NVARCHAR (MAX) NULL,
    [IdCountryCurrency]                    INT            NOT NULL,
    [IdCountry]                            INT            NOT NULL,
    [CountryName]                          NVARCHAR (MAX) NOT NULL,
    [IdCurrency]                           INT            NOT NULL,
    [CurrencyName]                         NVARCHAR (MAX) NOT NULL,
    [IdStatus]                             INT            NOT NULL,
    [StatusName]                           NVARCHAR (MAX) NOT NULL,
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
    [AgentCommissionExtra]                 MONEY          NULL,
    [AgentCommissionOriginal]              MONEY          NULL,
    [ModifierCommissionSlider]             MONEY          NULL,
    [ModifierExchangeRateSlider]           MONEY          NULL,
    [CustomerIdCarrier]                    INT            NULL,
    [ReviewDenyList]                       BIT            NULL,
    [ReviewOfac]                           BIT            NULL,
    [ReviewKYC]                            BIT            NULL,
    [IdSeller]                             INT            NOT NULL,
    [ReviewRejected]                       BIT            NULL,
    [ReviewGateway]                        BIT            NULL,
    [ReviewReturned]                       BIT            NULL,
    [OriginExRate]                         MONEY          NOT NULL,
    [OriginAmountInMN]                     MONEY          NOT NULL,
    [DateStatusChange]                     DATETIME       NULL,
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
    [IdPaymentMethod]                      INT            CONSTRAINT [DF_TransferClosed_PaymentMethod] DEFAULT ((1)) NOT NULL,
    [Discount]                             MONEY          CONSTRAINT [DF_TransferClosed_Discount] DEFAULT ((0)) NOT NULL,
    [DateOfTransferUTC]                    DATETIME       NULL,
    [OperationFee]                         MONEY          CONSTRAINT [DF_TransferClosed_OperationFee] DEFAULT ((0)) NOT NULL,
    [IsValidCustomerPhoneNumber]           BIT            NULL,
    [IdDialingCodePhoneNumber]             INT            NULL,
    [IdDialingCodeBeneficiaryPhoneNumber]  INT            NULL,
    [IsRequiredCustomerPhoneNumber]        BIT            NULL,
    [IsRefunded]                           BIT            NULL,
    CONSTRAINT [PK_TransferClosed_1] PRIMARY KEY CLUSTERED ([IdTransferClosed] ASC) WITH (FILLFACTOR = 90),
    FOREIGN KEY ([AccountTypeId]) REFERENCES [dbo].[AccountType] ([AccountTypeId]),
    FOREIGN KEY ([BeneficiaryIdCountryOfBirth]) REFERENCES [dbo].[CountryBirth] ([IdCountryBirth]),
    FOREIGN KEY ([CustomerIdCountryOfBirth]) REFERENCES [dbo].[CountryBirth] ([IdCountryBirth]),
    FOREIGN KEY ([IdDialingCodePhoneNumber]) REFERENCES [dbo].[DialingCodePhoneNumber] ([IdDialingCodePhoneNumber]),
    CONSTRAINT [FK_TransferCloded_Beneficiary_DialingCodePhoneNumber] FOREIGN KEY ([IdDialingCodeBeneficiaryPhoneNumber]) REFERENCES [dbo].[DialingCodePhoneNumber] ([IdDialingCodePhoneNumber]),
    CONSTRAINT [FK_TransferClosed_City] FOREIGN KEY ([TransferIdCity]) REFERENCES [dbo].[City] ([IdCity]),
    CONSTRAINT [FK_TransferClosed_PaymentMethod] FOREIGN KEY ([IdPaymentMethod]) REFERENCES [dbo].[PaymentMethod] ([IdPaymentMethod]),
    CONSTRAINT [FK_transferclosed_ReasonForCancel] FOREIGN KEY ([IdReasonForCancel]) REFERENCES [dbo].[ReasonForCancel] ([IdReasonForCancel])
);


GO
CREATE NONCLUSTERED INDEX [IDX_TransferClosed_IdCustomer]
    ON [dbo].[TransferClosed]([IdCustomer] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [ix_TransferClosed_IdCountryCurrency_DateOfTransfer]
    ON [dbo].[TransferClosed]([IdCountryCurrency] ASC, [DateOfTransfer] ASC)
    INCLUDE([IdPaymentType], [IdPayer], [IdGateway], [IdAgent], [AmountInDollars], [Fee], [AgentCommission], [ExRate], [ReferenceExRate]);


GO
CREATE NONCLUSTERED INDEX [ixBenStatus]
    ON [dbo].[TransferClosed]([IdBeneficiary] ASC, [IdStatus] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [ixClaimCode]
    ON [dbo].[TransferClosed]([ClaimCode] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [ix_TransferClosed_IdStatus_DateStatusChange_includes]
    ON [dbo].[TransferClosed]([IdStatus] ASC, [DateStatusChange] ASC, [DateOfTransfer] ASC)
    INCLUDE([IdTransferClosed], [IdPaymentType], [IdPayer], [IdGateway], [IdCountryCurrency], [ClaimCode], [AmountInDollars], [AmountInMN]);


GO
CREATE NONCLUSTERED INDEX [ix_TransferClosed_EnterByIdUser_DateOfTransfer_includes]
    ON [dbo].[TransferClosed]([EnterByIdUser] ASC, [DateOfTransfer] ASC)
    INCLUDE([IdStatus]);


GO
CREATE NONCLUSTERED INDEX [IX_TransferClosed_Folio_DateOfTransfer]
    ON [dbo].[TransferClosed]([Folio] ASC, [DateOfTransfer] ASC)
    INCLUDE([IdTransferClosed], [PaymentTypeName], [PayerName], [IdAgent], [IdCountry], [CountryName], [IdStatus], [StatusName], [ClaimCode], [AmountInDollars], [BeneficiaryName], [BeneficiaryFirstLastName], [BeneficiarySecondLastName], [CustomerName], [CustomerFirstLastName], [CustomerSecondLastName]);


GO
CREATE NONCLUSTERED INDEX [ix_TransferClosed_DateOfTransfer_includes]
    ON [dbo].[TransferClosed]([DateOfTransfer] ASC)
    INCLUDE([IdPaymentType], [IdPayer], [IdGateway], [IdAgent], [IdCountryCurrency], [AmountInDollars], [Fee], [AgentCommission], [ExRate], [ReferenceExRate]);


GO
CREATE NONCLUSTERED INDEX [IX_TransferClosed_IdAgent_DateOfTransfer_Folio_2]
    ON [dbo].[TransferClosed]([IdAgent] ASC, [DateOfTransfer] ASC, [Folio] ASC)
    INCLUDE([IdAgentPaymentSchema], [IdCountry], [IdCountryCurrency], [IdGateway], [IdPayer], [IdPaymentType]);


GO
CREATE STATISTICS [TransferClosed_Stadistic_IdCountryCurrency]
    ON [dbo].[TransferClosed]([IdCountryCurrency]);

