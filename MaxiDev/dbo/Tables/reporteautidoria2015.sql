﻿CREATE TABLE [dbo].[reporteautidoria2015] (
    [Statusname]                   NVARCHAR (MAX) NOT NULL,
    [ClaimCode]                    NVARCHAR (50)  NOT NULL,
    [DateOfTransfer]               DATETIME       NOT NULL,
    [AmountInDollars]              MONEY          NOT NULL,
    [AmountInMN]                   MONEY          NOT NULL,
    [customerfullname]             NVARCHAR (MAX) NULL,
    [CustomerName]                 NVARCHAR (MAX) NOT NULL,
    [CustomerFirstLastName]        NVARCHAR (MAX) NOT NULL,
    [CustomerSecondLastName]       NVARCHAR (MAX) NOT NULL,
    [CustomerAddress]              NVARCHAR (MAX) NOT NULL,
    [CustomerCity]                 NVARCHAR (MAX) NOT NULL,
    [CustomerState]                NVARCHAR (MAX) NOT NULL,
    [CustomerZipcode]              NVARCHAR (MAX) NOT NULL,
    [CustomerPhoneNumber]          NVARCHAR (MAX) NOT NULL,
    [CustomerCelullarNumber]       NVARCHAR (MAX) NOT NULL,
    [Name]                         NVARCHAR (MAX) NULL,
    [CustomerIdentificationNumber] NVARCHAR (MAX) NOT NULL,
    [CustomerSSNumber]             NVARCHAR (MAX) NOT NULL,
    [CustomerBornDate]             DATETIME       NULL,
    [CustomerOccupation]           NVARCHAR (MAX) NOT NULL,
    [DepositAccountNumber]         NVARCHAR (MAX) NOT NULL,
    [beneficiaryfullname]          NVARCHAR (MAX) NULL,
    [BeneficiaryName]              NVARCHAR (MAX) NOT NULL,
    [BeneficiaryFirstLastName]     NVARCHAR (MAX) NOT NULL,
    [BeneficiarySecondLastName]    NVARCHAR (MAX) NOT NULL,
    [RecipientAddress]             NVARCHAR (MAX) NOT NULL,
    [BeneficiaryPhoneNumber]       NVARCHAR (MAX) NOT NULL,
    [AgentCode]                    NVARCHAR (MAX) NOT NULL,
    [AgentName]                    NVARCHAR (MAX) NOT NULL,
    [AgentAddress]                 NVARCHAR (MAX) NOT NULL,
    [AgentCity]                    NVARCHAR (MAX) NOT NULL,
    [AgentState]                   NVARCHAR (MAX) NOT NULL,
    [AgentZipcode]                 NVARCHAR (MAX) NOT NULL,
    [PayerName]                    NVARCHAR (MAX) NULL,
    [Address]                      NVARCHAR (MAX) NULL,
    [CityName]                     NVARCHAR (MAX) NULL,
    [StateName]                    NVARCHAR (MAX) NULL,
    [IdBranch]                     INT            NULL,
    [PayBranchName]                NVARCHAR (MAX) NOT NULL,
    [PayDate]                      DATETIME       NULL,
    [PayCityName1]                 NVARCHAR (MAX) NOT NULL,
    [PayStateName1]                NVARCHAR (MAX) NOT NULL
);

