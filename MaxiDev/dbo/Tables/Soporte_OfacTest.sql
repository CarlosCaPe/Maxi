CREATE TABLE [dbo].[Soporte_OfacTest] (
    [Id]                        INT            IDENTITY (1, 1) NOT NULL,
    [IdTransfer]                INT            NULL,
    [DateOfTransfer]            DATETIME       NULL,
    [IsClosed]                  BIT            NULL,
    [CustomerName]              NVARCHAR (200) NULL,
    [CustomerFirstLastName]     NVARCHAR (200) NULL,
    [CustomerSecondLastName]    NVARCHAR (200) NULL,
    [CustomerEntNum]            BIGINT         NULL,
    [CustomerAltNum]            BIGINT         NULL,
    [CustomerQ]                 FLOAT (53)     NULL,
    [BeneficiaryName]           NVARCHAR (200) NULL,
    [BeneficiaryFirstLastName]  NVARCHAR (200) NULL,
    [BeneficiarySecondLastName] NVARCHAR (200) NULL,
    [BeneficiaryEntNum]         BIGINT         NULL,
    [BeneficiaryAltNum]         BIGINT         NULL,
    [BeneficiaryQ]              FLOAT (53)     NULL,
    [swCustomer]                BIGINT         NULL,
    [swBeneficary]              BIGINT         NULL,
    [Processed]                 BIT            NULL,
    UNIQUE NONCLUSTERED ([IdTransfer] ASC)
);

