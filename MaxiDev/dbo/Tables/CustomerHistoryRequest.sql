﻿CREATE TABLE [dbo].[CustomerHistoryRequest] (
    [IdCustomerHistoryRequest] INT            IDENTITY (1, 1) NOT NULL,
    [InitialDate]              DATE           NOT NULL,
    [FinalDate]                DATE           NOT NULL,
    [SelectedMoneyTransfer]    BIT            NOT NULL,
    [SelectedBillPayment]      BIT            NOT NULL,
    [SelectedTopUp]            BIT            NOT NULL,
    [IdCustomer]               INT            NOT NULL,
    [IdCustomerPhoneCode]      INT            NOT NULL,
    [CustomerPhoneNumber]      NVARCHAR (MAX) NOT NULL,
    [CustomerName]             NVARCHAR (MAX) NOT NULL,
    [CustomerLastName]         NVARCHAR (MAX) NOT NULL,
    [CustomerSecondLastName]   NVARCHAR (MAX) NOT NULL,
    [CustomerAddress]          NVARCHAR (MAX) NOT NULL,
    [CustomerZipCode]          NVARCHAR (MAX) NOT NULL,
    [Beneficiary]              NVARCHAR (MAX) NOT NULL,
    [IdIdentificationCountry]  INT            NOT NULL,
    [IdIdentificationType]     INT            NOT NULL,
    [IdentificationNumber]     NVARCHAR (MAX) NOT NULL,
    [SelectedCustomerEmail]    BIT            NOT NULL,
    [SelectedAgencyEmail]      BIT            NOT NULL,
    [SelectedAgencyFax]        BIT            NOT NULL,
    [DeliveryMethodText]       NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_ClientHistoryRequest] PRIMARY KEY CLUSTERED ([IdCustomerHistoryRequest] ASC),
    CONSTRAINT [FK_Country_CustomerHistoryRequest] FOREIGN KEY ([IdIdentificationCountry]) REFERENCES [dbo].[Country] ([IdCountry]),
    CONSTRAINT [FK_Customer_CustomerHistoryRequest] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_CustomerIdentificationType_CustomerHistoryRequest] FOREIGN KEY ([IdIdentificationType]) REFERENCES [dbo].[CustomerIdentificationType] ([IdCustomerIdentificationType]),
    CONSTRAINT [FK_DialingCodePhoneNumber_CustomerHistoryRequest] FOREIGN KEY ([IdCustomerPhoneCode]) REFERENCES [dbo].[DialingCodePhoneNumber] ([IdDialingCodePhoneNumber])
);

