﻿CREATE TABLE [Regalii].[Billers] (
    [IdBiller]                INT           NOT NULL,
    [Name]                    VARCHAR (500) NOT NULL,
    [Country]                 VARCHAR (500) NOT NULL,
    [BillerType]              VARCHAR (500) NOT NULL,
    [CanCheckBalance]         BIT           NOT NULL,
    [SupportsPartialPayments] BIT           NOT NULL,
    [RequiresNameOnAccount]   BIT           NOT NULL,
    [AvailableTopupAmounts]   VARCHAR (500) NOT NULL,
    [HoursToFulfill]          VARCHAR (500) NOT NULL,
    [LocalCurrency]           VARCHAR (500) NOT NULL,
    [AccountNumberDigits]     VARCHAR (500) NOT NULL,
    [Mask]                    VARCHAR (500) NOT NULL,
    [BillType]                VARCHAR (500) NOT NULL,
    [IdCountry]               INT           NULL,
    [IdCurrency]              INT           NULL,
    [TopUpCommission]         MONEY         NULL,
    [DateOfLastChange]        DATETIME      NULL,
    [IdGenericStatus]         INT           NULL,
    [IdOtherProduct]          INT           NULL,
    CONSTRAINT [PK_Billers] PRIMARY KEY CLUSTERED ([IdBiller] ASC),
    CONSTRAINT [FK_RegaliiBillers_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_RegaliiBillers_OtherProducts] FOREIGN KEY ([IdOtherProduct]) REFERENCES [dbo].[OtherProducts] ([IdOtherProducts])
);

