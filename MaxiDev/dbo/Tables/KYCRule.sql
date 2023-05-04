CREATE TABLE [dbo].[KYCRule] (
    [IdRule]                   INT             IDENTITY (1, 1) NOT NULL,
    [RuleName]                 NVARCHAR (MAX)  NULL,
    [IdPayer]                  INT             NULL,
    [IdPaymentType]            INT             NULL,
    [Actor]                    NVARCHAR (MAX)  NULL,
    [Symbol]                   NVARCHAR (MAX)  NULL,
    [Amount]                   MONEY           NULL,
    [AgentAmount]              BIT             NULL,
    [IdCountryCurrency]        INT             NULL,
    [TimeInDays]               INT             NULL,
    [Action]                   INT             NULL,
    [MessageInSpanish]         NVARCHAR (MAX)  NULL,
    [MessageInEnglish]         NVARCHAR (MAX)  NULL,
    [IdGenericStatus]          INT             NULL,
    [DateOfLastChange]         DATE            NULL,
    [EnterByIdUser]            INT             NULL,
    [IdAgent]                  INT             NULL,
    [IdCountry]                INT             NULL,
    [IdGateway]                INT             NULL,
    [Factor]                   DECIMAL (18, 2) NULL,
    [SSNRequired]              BIT             DEFAULT ((0)) NOT NULL,
    [IsConsecutive]            BIT             DEFAULT ((0)) NOT NULL,
    [Transactions]             INT             NULL,
    [IsExpire]                 BIT             DEFAULT ((0)) NOT NULL,
    [ExpirationDate]           DATETIME        NULL,
    [Creationdate]             DATETIME        NULL,
    [ComplianceFormatId]       INT             NULL,
    [OccupationRequired]       BIT             DEFAULT ((0)) NOT NULL,
    [IdState]                  INT             NULL,
    [IdStateDestination]       INT             NULL,
    [IdTypeRequired]           BIT             DEFAULT ((0)) NOT NULL,
    [IdNumberRequired]         BIT             DEFAULT ((0)) NOT NULL,
    [IdExpirationDateRequired] BIT             DEFAULT ((0)) NOT NULL,
    [IdStateCountryRequired]   BIT             DEFAULT ((0)) NOT NULL,
    [DateOfBirthRequired]      BIT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_KYCRule] PRIMARY KEY CLUSTERED ([IdRule] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [fk_ComplianceFormatKYCRule] FOREIGN KEY ([ComplianceFormatId]) REFERENCES [dbo].[ComplianceFormat] ([ComplianceFormatId]),
    CONSTRAINT [FK_KYCRule_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_KYCRule_Country] FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[Country] ([IdCountry]),
    CONSTRAINT [FK_KYCRule_CountryCurrency] FOREIGN KEY ([IdCountryCurrency]) REFERENCES [dbo].[CountryCurrency] ([IdCountryCurrency]),
    CONSTRAINT [FK_KYCRule_Gateway] FOREIGN KEY ([IdGateway]) REFERENCES [dbo].[Gateway] ([IdGateway]),
    CONSTRAINT [FK_KYCRule_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_KYCRule_Payer] FOREIGN KEY ([IdPayer]) REFERENCES [dbo].[Payer] ([IdPayer]),
    CONSTRAINT [FK_KYCRule_PaymentType] FOREIGN KEY ([IdPaymentType]) REFERENCES [dbo].[PaymentType] ([IdPaymentType])
);


GO
CREATE NONCLUSTERED INDEX [IX_KYCRule_IdPayer_Action_IdGenericStatus_IsExpire_TimeInDays_IdGateway]
    ON [dbo].[KYCRule]([IdPayer] ASC, [Action] ASC, [IdGenericStatus] ASC, [IsExpire] ASC, [TimeInDays] ASC, [IdGateway] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_KYCRule_IdGenericStatus_IdAgent]
    ON [dbo].[KYCRule]([IdGenericStatus] ASC, [IdAgent] ASC);

