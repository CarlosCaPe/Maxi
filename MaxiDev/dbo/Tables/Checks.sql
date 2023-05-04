CREATE TABLE [dbo].[Checks] (
    [IdCheck]                        INT           IDENTITY (1, 1) NOT NULL,
    [IdCustomer]                     INT           NOT NULL,
    [Name]                           VARCHAR (MAX) NULL,
    [FirstLastName]                  VARCHAR (MAX) NULL,
    [SecondLastName]                 VARCHAR (MAX) NULL,
    [IdentificationType]             VARCHAR (MAX) NULL,
    [State]                          VARCHAR (MAX) NULL,
    [DateOfBirth]                    DATETIME      NULL,
    [IdIdentificationType]           INT           NULL,
    [IdentificationDateOfExpiration] DATETIME      NULL,
    [Ocupation]                      VARCHAR (MAX) NULL,
    [IdentificationNumber]           VARCHAR (MAX) NULL,
    [CheckNumber]                    VARCHAR (MAX) NULL,
    [RoutingNumber]                  VARCHAR (MAX) NULL,
    [Account]                        VARCHAR (MAX) NULL,
    [IssuerName]                     VARCHAR (MAX) NULL,
    [DateOfIssue]                    DATETIME      NULL,
    [Amount]                         MONEY         NULL,
    [IsEndorsed]                     BIT           NULL,
    [IdStatus]                       INT           NOT NULL,
    [DateOfMovement]                 DATETIME      NULL,
    [DateStatusChange]               DATETIME      NULL,
    [DateOfLastChange]               DATETIME      NULL,
    [EnteredByIdUser]                INT           NULL,
    [IdAgent]                        INT           NULL,
    [ClaimCheck]                     VARCHAR (50)  NULL,
    [SSNumber]                       VARCHAR (MAX) NULL,
    [IdIssuer]                       INT           NULL,
    [TabNumber]                      INT           NULL,
    [BachCode]                       VARCHAR (MAX) NULL,
    [Comission]                      MONEY         NULL,
    [Fee]                            MONEY         NULL,
    [MicrAuxOnUs]                    VARCHAR (MAX) NULL,
    [MicrRoutingTransitNumber]       VARCHAR (MAX) NULL,
    [MicrOnUs]                       VARCHAR (MAX) NULL,
    [MicrAmount]                     VARCHAR (MAX) NULL,
    [MicrOriginal]                   VARCHAR (MAX) NULL,
    [IdCheckCredit]                  INT           NULL,
    [IdCheckBundle]                  INT           NULL,
    [MicrManual]                     VARCHAR (MAX) NULL,
    [CountryBirthId]                 INT           NULL,
    [IdCheckProcessorBank]           INT           NULL,
    [AgentNotificationSent]          INT           DEFAULT ((0)) NULL,
    [ValidationFee]                  MONEY         DEFAULT ((0)) NULL,
    [TransactionFee]                 MONEY         DEFAULT ((0)) NULL,
    [ReturnFee]                      MONEY         DEFAULT ((0)) NULL,
    [CheckFile]                      VARCHAR (100) DEFAULT (NULL) NULL,
    [CustomerFee]                    MONEY         DEFAULT ((0)) NULL,
    [IsIRD]                          BIT           NULL,
    [MicrEPC]                        VARCHAR (1)   NULL,
    [IsDateOfIssueBySystem]          BIT           CONSTRAINT [DF_Checks_IsDateOfIssueBySystem] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_Cheks] PRIMARY KEY CLUSTERED ([IdCheck] ASC),
    FOREIGN KEY ([CountryBirthId]) REFERENCES [dbo].[CountryBirth] ([IdCountryBirth]),
    CONSTRAINT [FK_Checks_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_Checks_CheckProcessorBank] FOREIGN KEY ([IdCheckProcessorBank]) REFERENCES [dbo].[CheckProcessorBank] ([IdCheckProcessorBank]),
    CONSTRAINT [FK_Cheks_Customer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_Cheks_CustomerIdentificationType] FOREIGN KEY ([IdIdentificationType]) REFERENCES [dbo].[CustomerIdentificationType] ([IdCustomerIdentificationType]),
    CONSTRAINT [FK_Cheks_Status] FOREIGN KEY ([IdStatus]) REFERENCES [dbo].[Status] ([IdStatus]),
    CONSTRAINT [FK_Cheks_Users] FOREIGN KEY ([EnteredByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IX_Checks_IdCustomer_IdStatus_DateOfMovement]
    ON [dbo].[Checks]([IdCustomer] ASC, [IdStatus] ASC, [DateOfMovement] ASC)
    INCLUDE([IdCheck]);


GO
CREATE NONCLUSTERED INDEX [IX_Checks_CountryBirthId]
    ON [dbo].[Checks]([CountryBirthId] ASC)
    INCLUDE([IdCheck], [IdCustomer]);


GO
CREATE NONCLUSTERED INDEX [IX_Checks_IdIssuer_IdStatus]
    ON [dbo].[Checks]([IdIssuer] ASC, [IdStatus] ASC, [DateOfMovement] ASC)
    INCLUDE([Amount]);


GO
CREATE NONCLUSTERED INDEX [IX_Checks_IdStatus_DateOfMovement_DateStatusChange_IdCheckProcessorBank]
    ON [dbo].[Checks]([IdStatus] ASC, [DateStatusChange] ASC, [DateOfMovement] ASC, [IdAgent] ASC, [IdCheckProcessorBank] ASC)
    INCLUDE([IdCheck], [IdIssuer], [Amount], [CheckNumber]);


GO
CREATE NONCLUSTERED INDEX [IX_Checks_IdCheckCredit]
    ON [dbo].[Checks]([IdCheckCredit] ASC)
    INCLUDE([CheckNumber], [Amount]);


GO
CREATE NONCLUSTERED INDEX [IX_Checks_EnteredByIdUser_IdAgent_DateOfMovement]
    ON [dbo].[Checks]([EnteredByIdUser] ASC, [IdAgent] ASC, [DateOfMovement] ASC)
    INCLUDE([IdCheck], [Amount], [Fee]);


GO
CREATE NONCLUSTERED INDEX [IX_Checks_IdCheckBundle]
    ON [dbo].[Checks]([IdCheckBundle] ASC)
    INCLUDE([IdCheck], [IdStatus], [DateStatusChange]);


GO
CREATE NONCLUSTERED INDEX [IX_Checks_Amount_IdCheckProcessorBank]
    ON [dbo].[Checks]([Amount] ASC, [IdCheckProcessorBank] ASC)
    INCLUDE([IdCheck], [CheckNumber], [RoutingNumber], [Account], [IdStatus], [IdAgent]);

