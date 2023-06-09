﻿CREATE TABLE [dbo].[AgentApplicationsResp05Agosto2021] (
    [IdAgentApplication]              INT            IDENTITY (1, 1) NOT NULL,
    [IdAgentApplicationCommunication] INT            NOT NULL,
    [IdUserSeller]                    INT            NOT NULL,
    [IdAgentApplicationStatus]        INT            NOT NULL,
    [IdAgentApplicationReceiptType]   INT            NOT NULL,
    [IdAgentApplicationBankDeposit]   INT            NULL,
    [IdAgentBusinessType]             INT            NOT NULL,
    [AgentName]                       NVARCHAR (MAX) NOT NULL,
    [AgentCode]                       NVARCHAR (MAX) NOT NULL,
    [AgentAddress]                    NVARCHAR (MAX) NOT NULL,
    [AgentCity]                       NVARCHAR (MAX) NOT NULL,
    [AgentState]                      NVARCHAR (MAX) NOT NULL,
    [AgentZipCode]                    NVARCHAR (MAX) NOT NULL,
    [AgentPhone]                      NVARCHAR (MAX) NOT NULL,
    [AgentFax]                        NVARCHAR (MAX) NOT NULL,
    [AgentContact]                    NVARCHAR (MAX) NOT NULL,
    [AgentTimeInBusiness]             DATETIME       NULL,
    [AgentActivity]                   NVARCHAR (MAX) NULL,
    [GuarantorName]                   NVARCHAR (MAX) NULL,
    [GuarantorLastName]               NVARCHAR (MAX) NULL,
    [GuarantorSecondLastName]         NVARCHAR (MAX) NULL,
    [GuarantorAddress]                NVARCHAR (MAX) NULL,
    [GuarantorCity]                   NVARCHAR (MAX) NULL,
    [GuarantorState]                  NVARCHAR (MAX) NULL,
    [GuarantorZipCode]                NVARCHAR (MAX) NULL,
    [GuarantorPhone]                  NVARCHAR (MAX) NULL,
    [GuarantorCel]                    NVARCHAR (MAX) NULL,
    [GuarantorEmail]                  NVARCHAR (MAX) NULL,
    [GuarantorSsn]                    NVARCHAR (MAX) NULL,
    [GuarantorIdType]                 INT            NULL,
    [GuarantorIdNumber]               NVARCHAR (MAX) NULL,
    [GuarantorIdExpirationDate]       DATE           NULL,
    [GuarantorBornDate]               DATE           NULL,
    [GuarantorCreditScore]            NVARCHAR (MAX) NULL,
    [GuarantorBornCountry]            NVARCHAR (MAX) NULL,
    [GuarantorTitle]                  NVARCHAR (MAX) NULL,
    [TaxId]                           NVARCHAR (MAX) NOT NULL,
    [Notes]                           NVARCHAR (MAX) NOT NULL,
    [BusinessPermissionNumber]        NVARCHAR (MAX) NOT NULL,
    [BusinessPermissionExpiration]    DATE           NOT NULL,
    [DoneOnSundayPayOn]               INT            NOT NULL,
    [DoneOnMondayPayOn]               INT            NOT NULL,
    [DoneOnTuesdayPayOn]              INT            NOT NULL,
    [DoneOnWednesdayPayOn]            INT            NOT NULL,
    [DoneOnThursdayPayOn]             INT            NOT NULL,
    [DoneOnFridayPayOn]               INT            NOT NULL,
    [DoneOnSaturdayPayOn]             INT            NOT NULL,
    [CommissionAgent]                 DECIMAL (5, 2) NOT NULL,
    [CommissionCorp]                  DECIMAL (5, 2) NOT NULL,
    [HasBillPayment]                  BIT            NOT NULL,
    [HasFlexStatus]                   BIT            NOT NULL,
    [DateOfLastChange]                DATETIME       NOT NULL,
    [EnterByIdUser]                   INT            NOT NULL,
    [HasAch]                          BIT            NOT NULL,
    [DateOfCreation]                  DATETIME       NOT NULL,
    [OfacOwnerChecked]                BIT            NULL,
    [OfacGuarantorChecked]            BIT            NULL,
    [OfacBusinessChecked]             BIT            NULL,
    [CommissionAgentOtherCountries]   DECIMAL (5, 2) NOT NULL,
    [CommissionCorpOtherCountries]    DECIMAL (5, 2) NOT NULL,
    [IdOwner]                         INT            NULL,
    [IdAgentClass]                    INT            NULL,
    [DoingBusinessAs]                 NVARCHAR (MAX) NULL,
    [IdAgentPaymentSchema]            INT            DEFAULT ((1)) NOT NULL,
    [RetainMoneyCommission]           BIT            DEFAULT ((0)) NOT NULL,
    [IdAgentCommissionPay]            INT            NULL,
    [AccountNumberCommission]         NVARCHAR (MAX) NULL,
    [RoutingNumberCommission]         NVARCHAR (MAX) NULL,
    [IdCounty]                        INT            NULL,
    [IdCountyGuarantor]               INT            NULL,
    [NeedsWFSubaccount]               BIT            DEFAULT ((0)) NOT NULL,
    [RequestWFSubaccount]             BIT            DEFAULT ((0)) NOT NULL,
    [NeedsWFSubaccountDate]           DATETIME       DEFAULT ('19000101') NOT NULL,
    [NeedsWFSubaccountIduser]         INT            DEFAULT ((0)) NOT NULL,
    [RequestWFSubaccountDate]         DATETIME       DEFAULT ('19000101') NOT NULL,
    [RequestWFSubaccountIdUser]       INT            DEFAULT ((0)) NOT NULL,
    [IdAgentsReportWellsFargo]        INT            DEFAULT ((0)) NOT NULL,
    [IsVerifiedAddress]               BIT            DEFAULT ((0)) NULL,
    [ComplianceOfficerTitle]          VARCHAR (200)  NULL,
    [ComplianceOfficerName]           VARCHAR (200)  NULL,
    [EntityType]                      INT            NULL,
    [Email]                           NVARCHAR (80)  NULL,
    [Website]                         NVARCHAR (100) NULL,
    [Activity]                        INT            NULL,
    [FinCENReg]                       BIT            NULL,
    [Expiration]                      DATE           NULL,
    [CheckCasher]                     BIT            NULL,
    [License]                         BIT            NULL,
    [LicenseNumber]                   NVARCHAR (20)  NULL,
    [ComissionInfo]                   INT            NULL,
    [MailCheckto]                     INT            NULL,
    [DateOfBirth]                     DATE           NULL,
    [PlaceOfBirth]                    NVARCHAR (5)   NULL,
    [BillPayment]                     BIT            NULL,
    [FotoNegocioInterior]             INT            NULL,
    [AgentPorcientoFeeGuatemala]      NUMERIC (18)   NULL,
    [AgentPorcientoFeeHonduras]       NUMERIC (18)   NULL,
    [AgentPorcientoFeeElSalvador]     NUMERIC (18)   NULL,
    [ExceptionsCountry]               INT            NULL,
    [ExceptionsPayer]                 INT            NULL,
    [ExceptionsAgentPorcientoOfFee]   NUMERIC (18)   NULL,
    CONSTRAINT [PK_AgentApplicationR] PRIMARY KEY CLUSTERED ([IdAgentApplication] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentApplication_AgentApplicationStatusR] FOREIGN KEY ([IdAgentApplicationStatus]) REFERENCES [dbo].[AgentApplicationStatuses] ([IdAgentApplicationStatus]),
    CONSTRAINT [FK_AgentApplication_AgentBankDepositR] FOREIGN KEY ([IdAgentApplicationBankDeposit]) REFERENCES [dbo].[AgentBankDeposit] ([IdAgentBankDeposit]),
    CONSTRAINT [FK_AgentApplication_AgentBusinessTypeR] FOREIGN KEY ([IdAgentBusinessType]) REFERENCES [dbo].[AgentBusinessTypes] ([IdAgentBusinessType]),
    CONSTRAINT [FK_AgentApplication_AgentCommunicationR] FOREIGN KEY ([IdAgentApplicationCommunication]) REFERENCES [dbo].[AgentCommunication] ([IdAgentCommunication]),
    CONSTRAINT [FK_AgentApplication_AgentReceiptTypeR] FOREIGN KEY ([IdAgentApplicationReceiptType]) REFERENCES [dbo].[AgentReceiptType] ([IdAgentReceiptType]),
    CONSTRAINT [FK_AgentApplication_Users2R] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [FK_AgentApplication_UsersR] FOREIGN KEY ([IdUserSeller]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [FK_AgentApplications_AgentPaymentSchemaR] FOREIGN KEY ([IdAgentPaymentSchema]) REFERENCES [dbo].[AgentPaymentSchema] ([IdAgentPaymentSchema]),
    CONSTRAINT [FK_AgentApplications_IdAgentCommissionPayR] FOREIGN KEY ([IdAgentCommissionPay]) REFERENCES [dbo].[AgentCommissionPay] ([IdAgentCommissionPay])
);


GO
CREATE NONCLUSTERED INDEX [IX_AgentApplications_IdAgentApplicationStatus]
    ON [dbo].[AgentApplicationsResp05Agosto2021]([IdAgentApplicationStatus] ASC)
    INCLUDE([IdAgentApplication]);


GO
CREATE NONCLUSTERED INDEX [IX_AgentApplications_DateOfCreation]
    ON [dbo].[AgentApplicationsResp05Agosto2021]([DateOfCreation] ASC)
    INCLUDE([IdAgentApplication], [IdUserSeller], [IdAgentApplicationStatus], [NeedsWFSubaccount], [RequestWFSubaccount]);

