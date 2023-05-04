CREATE TABLE [moneyalert].[Beneficiary] (
    [IdBeneficiary]       INT      NOT NULL,
    [IdBeneficiaryMobile] INT      NOT NULL,
    [EnteredDate]         DATETIME NOT NULL,
    [DateOfLastChange]    DATETIME NOT NULL,
    CONSTRAINT [PK_Beneficiary_1] PRIMARY KEY CLUSTERED ([IdBeneficiary] ASC),
    CONSTRAINT [FK_Beneficiary_BeneficiaryMobile] FOREIGN KEY ([IdBeneficiaryMobile]) REFERENCES [moneyalert].[BeneficiaryMobile] ([IdBeneficiaryMobile])
);

