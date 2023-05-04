CREATE TABLE [dbo].[PreTransfer] (
    [IdPreTransfer]                        INT            IDENTITY (1, 1) NOT NULL,
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
    [AmountInDollars]                      MONEY          NOT NULL,
    [Fee]                                  MONEY          NOT NULL,
    [AgentCommission]                      MONEY          NOT NULL,
    [CorporateCommission]                  MONEY          NOT NULL,
    [DateOfPreTransfer]                    DATETIME       NOT NULL,
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
    [OriginExRate]                         MONEY          NOT NULL,
    [OriginAmountInMN]                     MONEY          NOT NULL,
    [NoteAdditional]                       NVARCHAR (MAX) NULL,
    [CustomerIdentificationIdCountry]      INT            NULL,
    [CustomerIdentificationIdState]        INT            NULL,
    [BrokenRules]                          XML            NULL,
    [IdCity]                               INT            NULL,
    [StateTax]                             MONEY          NULL,
    [OWBRuleType]                          INT            NULL,
    [TransferAmount]                       MONEY          NULL,
    [IsValid]                              BIT            DEFAULT ((0)) NOT NULL,
    [IdTransferResend]                     INT            NULL,
    [Status]                               BIT            DEFAULT ((0)) NOT NULL,
    [IdTransfer]                           INT            NULL,
    [IdBeneficiaryIdentificationType]      INT            NULL,
    [BeneficiaryIdentificationNumber]      NVARCHAR (MAX) NULL,
    [CustomerIdCountryOfBirth]             INT            NULL,
    [BeneficiaryIdCountryOfBirth]          INT            NULL,
    [AccountTypeId]                        INT            NULL,
    [CustomerOccupationDetail]             NVARCHAR (MAX) DEFAULT (NULL) NULL,
    [TransferIdCity]                       INT            DEFAULT (NULL) NULL,
    [BeneficiaryIdCarrier]                 INT            DEFAULT (NULL) NULL,
    [CustomerIdOccupation]                 INT            NULL,
    [CustomerIdSubOccupation]              INT            NULL,
    [CustomerSubOccupationOther]           VARCHAR (50)   NULL,
    [CustomerOFACMatch]                    XML            NULL,
    [BeneficiaryOFACMatch]                 XML            NULL,
    [OnlineTransfer]                       BIT            DEFAULT ((0)) NOT NULL,
    [SendMoneyAlertInvitation]             BIT            DEFAULT ((0)) NOT NULL,
    [IdTransferOriginal]                   INT            NULL,
    [IsModify]                             BIT            DEFAULT ((0)) NULL,
    [IdPaymentMethod]                      INT            CONSTRAINT [DF_PreTransfer_PaymentMethod] DEFAULT ((1)) NOT NULL,
    [Discount]                             MONEY          CONSTRAINT [DF_PreTransfer_Discount] DEFAULT ((0)) NOT NULL,
    [DateOfPreTransferUTC]                 DATETIME       NULL,
    [OperationFee]                         MONEY          CONSTRAINT [DF_PreTransfer_OperationFee] DEFAULT ((0)) NOT NULL,
    [IsValidCustomerPhoneNumber]           BIT            NULL,
    [IdDialingCodePhoneNumber]             INT            NULL,
    [IdDialingCodeBeneficiaryPhoneNumber]  INT            NULL,
    CONSTRAINT [PK_PreTransfer] PRIMARY KEY CLUSTERED ([IdPreTransfer] ASC) WITH (FILLFACTOR = 90),
    FOREIGN KEY ([AccountTypeId]) REFERENCES [dbo].[AccountType] ([AccountTypeId]),
    FOREIGN KEY ([BeneficiaryIdCountryOfBirth]) REFERENCES [dbo].[CountryBirth] ([IdCountryBirth]),
    FOREIGN KEY ([CustomerIdCountryOfBirth]) REFERENCES [dbo].[CountryBirth] ([IdCountryBirth]),
    FOREIGN KEY ([IdDialingCodePhoneNumber]) REFERENCES [dbo].[DialingCodePhoneNumber] ([IdDialingCodePhoneNumber]),
    CONSTRAINT [FK_PreTransfer_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_PreTransfer_Beneficiary] FOREIGN KEY ([IdBeneficiary]) REFERENCES [dbo].[Beneficiary] ([IdBeneficiary]),
    CONSTRAINT [FK_PreTransfer_Beneficiary_DialingCodePhoneNumber] FOREIGN KEY ([IdDialingCodeBeneficiaryPhoneNumber]) REFERENCES [dbo].[DialingCodePhoneNumber] ([IdDialingCodePhoneNumber]),
    CONSTRAINT [FK_PreTransfer_Branch] FOREIGN KEY ([IdBranch]) REFERENCES [dbo].[Branch] ([IdBranch]),
    CONSTRAINT [FK_PreTransfer_City] FOREIGN KEY ([TransferIdCity]) REFERENCES [dbo].[City] ([IdCity]),
    CONSTRAINT [FK_PreTransfer_Country] FOREIGN KEY ([CustomerIdentificationIdCountry]) REFERENCES [dbo].[Country] ([IdCountry]),
    CONSTRAINT [FK_PreTransfer_CountryCurrency] FOREIGN KEY ([IdCountryCurrency]) REFERENCES [dbo].[CountryCurrency] ([IdCountryCurrency]),
    CONSTRAINT [FK_PreTransfer_Customer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_PreTransfer_Gateway] FOREIGN KEY ([IdGateway]) REFERENCES [dbo].[Gateway] ([IdGateway]),
    CONSTRAINT [FK_PreTransfer_OnWhoseBehalf] FOREIGN KEY ([IdOnWhoseBehalf]) REFERENCES [dbo].[OnWhoseBehalf] ([IdOnWhoseBehalf]),
    CONSTRAINT [FK_PreTransfer_Payer] FOREIGN KEY ([IdPayer]) REFERENCES [dbo].[Payer] ([IdPayer]),
    CONSTRAINT [FK_PreTransfer_PaymentMethod] FOREIGN KEY ([IdPaymentMethod]) REFERENCES [dbo].[PaymentMethod] ([IdPaymentMethod]),
    CONSTRAINT [FK_PreTransfer_PaymentType] FOREIGN KEY ([IdPaymentType]) REFERENCES [dbo].[PaymentType] ([IdPaymentType]),
    CONSTRAINT [FK_PreTransfer_State] FOREIGN KEY ([CustomerIdentificationIdState]) REFERENCES [dbo].[State] ([IdState]),
    CONSTRAINT [FK_PretransferBeneficiary_IDType] FOREIGN KEY ([IdBeneficiaryIdentificationType]) REFERENCES [dbo].[BeneficiaryIdentificationType] ([IdBeneficiaryIdentificationType])
);


GO
CREATE NONCLUSTERED INDEX [ix_PreTransfer_EnterByIdUser]
    ON [dbo].[PreTransfer]([EnterByIdUser] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PreTransfer_IdPaymentType_IdPayer_IdGateway_IdAgentSchema_IdCountryCurrency_IsValid]
    ON [dbo].[PreTransfer]([IdPaymentType] ASC, [IdPayer] ASC, [IdGateway] ASC, [IdAgentSchema] ASC, [IdCountryCurrency] ASC, [IsValid] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PreTransfer_IdTransfer]
    ON [dbo].[PreTransfer]([IdTransfer] ASC)
    INCLUDE([IdPreTransfer]);


GO
CREATE NONCLUSTERED INDEX [IX_PreTransfer_IdCountryCurrency_OriginExRate_IsValid]
    ON [dbo].[PreTransfer]([IdCountryCurrency] ASC, [OriginExRate] ASC, [IsValid] ASC)
    INCLUDE([IdPreTransfer], [IdPaymentType], [IdPayer], [IdGateway], [IdAgent], [IdAgentSchema], [AmountInDollars], [IdCity]);


GO
CREATE NONCLUSTERED INDEX [IX_PreTransfer_IdAgent_Status]
    ON [dbo].[PreTransfer]([IdAgent] ASC, [Status] ASC);

